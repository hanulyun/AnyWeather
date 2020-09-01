//
//  HTTPClient+Request.swift
//  KPCore
//
//  Created by henry on 2018. 1. 30..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension HTTPClient {
    
    @discardableResult
    public func request<ResponseData: Decodable>(urlString: String, method: Method = .get,
                                                 headers: [String: String]? = nil,
                                                 parameters: [String: Any]? = nil, parameterEncoding: URLRequest.ParameterEncoding? = .form,
                                                 parseType: ResponseData.Type? = nil, completionHandler: @escaping (ResponseData?, Error?) -> Void) -> URLSessionDataTask? {
        // request
        guard let urlRequest = makeRequest(urlString: urlString, method: method, headers: headers, parameters: parameters, parameterEncoding: parameterEncoding) else {
            return nil
        }
        
        // response
        return self.request(urlRequest, method: method, completionHandler: completionHandler)
    }
    
    // Dictionary<String, Any>, UIImage 와 같이 Decodable 이 지원되지 않지만, Data 로 표현될 수 있는 객체들을 파싱하는 용도로 사용합니다.
    @discardableResult
    public func request<ResponseData: DataRepresentable>(urlString: String, method: Method = .get,
                                                         headers: [String: String]? = nil,
                                                         parameters: [String: Any]? = nil, parameterEncoding: URLRequest.ParameterEncoding? = .form,
                                                         completionHandler: @escaping (ResponseData?, Error?) -> Void) -> URLSessionDataTask? {
        // request
        guard let urlRequest = makeRequest(urlString: urlString, method: method, headers: headers, parameters: parameters, parameterEncoding: parameterEncoding) else {
            return nil
        }
        
        // response
        return self.request(urlRequest, method: method, completionHandler: completionHandler)
    }
    
    
    @discardableResult
    public func downloadRequest(urlString: String,
                                headers: [String: String]? = nil,
                                parameters: [String: Any]? = nil,
                                parameterEncoding: URLRequest.ParameterEncoding? = .form,
                                completionHandler: @escaping (URL?, Error?) -> Void) -> URLSessionDownloadTask? {
        guard let urlRequest = makeRequest(urlString: urlString, method: .get, headers: headers, parameters: parameters, parameterEncoding: parameterEncoding) else {
            return nil
        }
        
        // response
        return self.requestDownload(urlRequest, completionHandler: completionHandler)
    }
    
    @discardableResult
    public func uploadRequest<ResponseData: Decodable>(urlString: String,
                                                       method: Method = .post,
                                                       headers: [String: String]? = nil,
                                                       parameters: [String: Any]? = nil,
                                                       multipartValues: [MultipartValue],
                                                       parseType: ResponseData.Type? = nil,
                                                       completionHandler: @escaping (ResponseData?, Error?) -> Void) -> URLSessionDataTask? {
        guard var urlRequest = makeRequest(urlString: urlString, method: method, headers: headers, parameters: parameters, parameterEncoding: .multipart) else {
            return nil
        }
        let boundary = createBoundary()
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let multipartData = makeMultipartBody(parameters: parameters, boundary: boundary, multipartValues: multipartValues)
        
        return self.requestUpload(urlRequest, method: method, data: multipartData, completionHandler: completionHandler)
    }
    
    public func cancelAllRequests() {
        self.session.getAllTasks { (allTasks) in
            for task in allTasks {
                task.cancel()
            }
        }
    }
}
