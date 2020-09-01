//
//  URLRequest+ParameterEncoding.swift
//  KPCore
//
//  Created by henry on 2018. 1. 25..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension URLRequest {
    
    public enum ParameterEncoding: String {
        case form
        case json
        case multipart
    }
    
    public init?(url: URL, method: String, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval, headers: [String: String]?, parameters: [String: Any]?, parameterEncoding: ParameterEncoding?) {
        self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)

        httpMethod = method
        if let parameters = parameters, let encoding = parameterEncoding, encoding != .multipart {
            setParameters(parameters: parameters, encoding: encoding)
        }
        
        if let headers = headers {
            for (headerField, headerValue) in headers {
                setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
    }
    
    private func canEncodeParametersInURL() -> Bool {
        guard let uppercasedHttpMethod = self.httpMethod?.uppercased() else {
            return false
        }
        
        switch uppercasedHttpMethod {
        case "GET", "HEAD", "DELETE":
            return true
        default:
            return false
        }
    }
    
    public mutating func setParameters(parameters: [String: Any], encoding: ParameterEncoding) {
        guard let url = self.url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        
        self.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "accept")
        
        // try parameter encoding if possible
        let queryItems = parameters.map { (name, value) -> URLQueryItem in
            return URLQueryItem(name: name, value: "\(value)")
        }
        urlComponents.queryItems = queryItems
        
        if canEncodeParametersInURL() {
            if !queryItems.isEmpty { self.url = urlComponents.url }
            return
        }
        
        switch encoding {
        case .form:
            // form url encoding
            self.httpBody = urlComponents.percentEncodedQuery?.data(using: .utf8)
            self.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
        case .json:
            // json encoding
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                self.httpBody = jsonData
                self.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            } catch {
                return
            }
        case .multipart:
            break
        }
    }
}

