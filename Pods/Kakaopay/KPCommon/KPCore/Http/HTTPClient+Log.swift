//
//  HTTPClient+Log.swift
//  KPCore
//
//  Created by henry on 2018. 4. 9..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension HTTPClient {
    
    public enum LogLevel: String {
        case none
        case onlyError
        case compact
        case full
    }
    
    internal func printRequestLog(_ urlRequest: URLRequest, _ parameters: [String: Any]?, _ parameterEncoding: URLRequest.ParameterEncoding?) {
        if self.logLevel == .full {
            var requestLog = "\n[HTTPClient::Request]\n"
            if let urlString = urlRequest.url?.absoluteString { requestLog += "URL: \(urlString)\n" }
            if let method = urlRequest.httpMethod { requestLog += "Method: \(method)\n" }
            if let headers = urlRequest.allHTTPHeaderFields { requestLog += "Request Headers: \(headers)\n" }
            if let encoding = parameterEncoding?.rawValue { requestLog += "ParameterEncoding: \(encoding)\n" }
            if let params = parameters { requestLog += "Parameters: \(params)\n" }
            if let body = urlRequest.httpBody { requestLog += "Body: \(body)" }
            print(requestLog)
            
        } else if self.logLevel == .compact {
            var requestLog = "[HTTPClient::Request]"
            if let method = urlRequest.httpMethod { requestLog += " (\(method))" }
            if let urlString = urlRequest.url?.absoluteString { requestLog += " \(urlString)" }
            print(requestLog)
        }
    }
    
    internal func printResponseLog<ResponseData>(_ response: Response, _ result: ResponseData?, _ duration: TimeInterval) {
        let maybeData = response.maybeData
        let maybeResponse = response.maybeResponse
        let maybeError = response.maybeError
        
        let responseTime = "[\(Int((duration * 1000.0).rounded()))ms]"
        if self.logLevel == .full {
            var responseLog = "\n[HTTPClient::Response] \(responseTime) \n"
            if let debugResponse = maybeResponse as? HTTPURLResponse {
                if let urlString = debugResponse.url?.absoluteString { responseLog += "URL: \(urlString)\n" }
                responseLog += "Status Code: \(debugResponse.statusCode)\n"
                if let headers = debugResponse.allHeaderFields as? [String: String] { responseLog += "Response Headers: \(headers)\n" }
                if let mimeType = debugResponse.mimeType { responseLog += "MimeType: \(mimeType)\n" }
                if let mimeType = debugResponse.mimeType,
                    mimeType.contains("application") || mimeType.contains("text") {
                    // print result as String
                    if let data = maybeData,
                        let string = String(data: data, encoding: .utf8) {
                        responseLog += "Response: \(string)\n"
                    }
                } else if let responseResult = result {
                    // print result as object
                    responseLog += "Response: \(responseResult)\n"
                }
            } else if let debugError = maybeError { responseLog += "Error: \(debugError.localizedDescription)\n" }
            print(responseLog)
            
        } else if self.logLevel == .compact {
            var responseLog = "[HTTPClient::Response]"
            if let debugResponse = maybeResponse as? HTTPURLResponse {
                responseLog += " (\(debugResponse.statusCode)) \(responseTime)"
                if let urlString = debugResponse.url?.absoluteString { responseLog += " \(urlString)" }
                if !debugResponse.isValidateStatusCode() {
                    if let mimeType = debugResponse.mimeType,
                        mimeType.contains("application") || mimeType.contains("text") {
                        if let data = maybeData,
                            let string = String(data: data, encoding: .utf8) {
                            responseLog += "\n\(string)"
                        }
                    } else if let responseResult = result {
                        responseLog += "\n\(responseResult)"
                    }
                }
            } else if let debugError = maybeError { responseLog += " \(debugError.localizedDescription)" }
            print(responseLog)
        } else if self.logLevel == .onlyError {
            var responseLog = "[HTTPClient::Response]"
            if let debugResponse = maybeResponse as? HTTPURLResponse {
                if !debugResponse.isValidateStatusCode() {
                    responseLog += " (\(debugResponse.statusCode)) \(responseTime)"
                    if let urlString = debugResponse.url?.absoluteString { responseLog += " \(urlString)" }
                    if let mimeType = debugResponse.mimeType,
                        mimeType.contains("application") || mimeType.contains("text") {
                        if let data = maybeData,
                            let string = String(data: data, encoding: .utf8) {
                            responseLog += "\nResponse: \(string)"
                        }
                    } else if let responseResult = result {
                        responseLog += "\nResponse: \(responseResult)"
                    }
                    print(responseLog)
                }
            } else if let debugError = maybeError {
                responseLog += " \(responseTime) \(debugError.localizedDescription)"
                print(responseLog)
            }
        }
    }
}
