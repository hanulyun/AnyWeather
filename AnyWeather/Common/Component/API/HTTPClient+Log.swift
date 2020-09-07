//
//  HTTPClient+Log.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Kakaopay

extension HTTPClient {
    
    static func requestWillStartLog(urlRequest: URLRequest, parameters: [String: Any]?,
                                    parameterEncoding: URLRequest.ParameterEncoding?) {
        
        guard let path: String = urlRequest.url?.path else { return }
        let method: String = urlRequest.httpMethod ?? "??"
        var requestLog: String = "[API] \(method) \(path)\n"
        if let urlString: String = urlRequest.url?.absoluteString { requestLog += "URL: \(urlString)\n" }
        if let headers: [String: String]
            = urlRequest.allHTTPHeaderFields { requestLog += "Request Headers: \(headers)\n" }
        if let encoding: String = parameterEncoding?.rawValue { requestLog += "ParameterEncoding: \(encoding)\n" }
        if let params: [String: Any] = parameters { requestLog += "Parameters: \(params)\n" }
        if let body: Data = urlRequest.httpBody { requestLog += "Body: \(body)" }
        
        Log.debug(requestLog)
    }
    
    static func requestDidEndLog(urlRequest: URLRequest,
                                 response: HTTPClient.Response, duration: TimeInterval) {
        
        guard let path: String = urlRequest.url?.path else { return }
        let maybeData: Data? = response.maybeData
        let maybeResponse: URLResponse? = response.maybeResponse
        let maybeError: Error? = response.maybeError
        let responseTime: String = "[\(Int((duration * 1000.0).rounded()))ms]"
        var responseLog: String = "[API] \((maybeError == nil) ? "👍":"🛑") \(responseTime) \(path)\n"
        
        if let debugResponse: HTTPURLResponse = maybeResponse as? HTTPURLResponse {
            if let urlString: String = debugResponse.url?.absoluteString { responseLog += "URL: \(urlString)\n" }
            responseLog += "Status Code: \(debugResponse.statusCode)\n"
            if let headers: [String: String] = debugResponse.allHeaderFields as? [String: String] { responseLog += "Response Headers: \(headers)\n" }
            if let mimeType: String = debugResponse.mimeType { responseLog += "MimeType: \(mimeType)\n" }
            if let mimeType: String = debugResponse.mimeType,
                mimeType.contains("application") || mimeType.contains("text") {
                // print result as String
                if let data: Data = maybeData,
                    let string: String = String(data: data, encoding: .utf8) {
                    responseLog += "Response: \(string)\n"
                }
            }
            if let debugError: Error = maybeError { responseLog += "Error: \(debugError.localizedDescription)\n" }
        } else if let debugError = maybeError { responseLog += "Error: \(debugError.localizedDescription)\n" }
        
        Log.debug(responseLog)
    }
}
