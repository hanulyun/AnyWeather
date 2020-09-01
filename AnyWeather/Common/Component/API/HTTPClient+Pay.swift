//
//  HTTPClient+Pay.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Kakaopay
import Promises

extension URLSessionConfiguration {
    static var pay: URLSessionConfiguration = {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 20
        return config
    }()
}

extension HTTPClient {
    enum ValidateError: Error {
        case urlCancelled
        
        var localizedDescription: String {
            switch self {
            case .urlCancelled:
                return "네트워크 취소 (NSURLErrorCancelled)"
            }
        }
    }
    
    static var pay: HTTPClient = {
        let client: HTTPClient = HTTPClient(sessionConfiguration: URLSessionConfiguration.pay, on: nil)
        client.decoder.dateDecodingStrategy = .millisecondsSince1970
        
        // provider
        client.responseValidateProvider = HTTPClient.responseValidateProvider

        // log
        client.requestWillStart = HTTPClient.requestWillStartLog
        client.requestDidEnd = HTTPClient.requestDidEndLog
        
        return client
    }()
    
    static func responseValidateProvider(maybeData: Data?,
                                         maybeResponse: URLResponse?, maybeError: Error?) throws {
        
        if let error: Error = maybeError, (error as NSError).code == NSURLErrorCancelled {
            throw ValidateError.urlCancelled
        }
        
        guard let httpResponse: HTTPURLResponse = maybeResponse as? HTTPURLResponse else {
            throw HTTPClient.ResponseError.unhandled(error: maybeError)
        }
        
        if httpResponse.isValidateStatusCode() {
            return
        }
        
        let statusCode: Int = httpResponse.statusCode
        switch statusCode {
        case 400..<500:
            throw HTTPClient.SessionError.invalidSession
        case 500..<600:
            throw HTTPClient.SessionError.invalidStatusCode
        default:
            throw HTTPClient.SessionError.unhandled
        }
    }
}
