//
//  HTTPClient+Internal.swift
//  Kakaopay
//
//  Created by henry.my on 23/09/2019.
//

import Foundation

extension HTTPClient {
    internal func request<ResultData: Decodable>(_ urlRequest: URLRequest, method: Method, completionHandler: @escaping (ResultData?, Error?) -> Void) -> URLSessionDataTask? {
        let firedTime = Date().timeIntervalSince1970
        let dataTask = session.dataTask(with: urlRequest) { maybeData, maybeResponse, maybeError in
            let response = (method == .mock) ? MockResponse(maybeData, maybeResponse, maybeError) : Response(maybeData, maybeResponse, maybeError)
            var result: ResultData?
            do {
                if let responseValidateProvider = self.responseValidateProvider {
                    try responseValidateProvider(response.maybeData, response.maybeResponse, response.maybeError)
                } else {
                    try self.validateResponse(data: maybeData, httpResponse: maybeResponse, maybeError: maybeError)
                }
                result = self.parse(response: response)
            } catch let error {
                response.maybeError = error
            }
            self.handleCompletion(urlRequest: urlRequest, response: response, result: result, method: method, duration: Date().timeIntervalSince1970 - firedTime, completionHandler: completionHandler)
        }
        if startImmediately { dataTask.resume() }
        return dataTask
    }
    
    internal func request<ResultData: DataRepresentable>(_ urlRequest: URLRequest, method: Method, completionHandler: @escaping (ResultData?, Error?) -> Void) -> URLSessionDataTask? {
        let firedTime = Date().timeIntervalSince1970
        let dataTask = session.dataTask(with: urlRequest) { maybeData, maybeResponse, maybeError in
            let response = (method == .mock) ? MockResponse(maybeData, maybeResponse, maybeError) : Response(maybeData, maybeResponse, maybeError)
            var result: ResultData?
            do {
                if let responseValidateProvider = self.responseValidateProvider {
                    try responseValidateProvider(response.maybeData, response.maybeResponse, response.maybeError)
                } else {
                    try self.validateResponse(data: maybeData, httpResponse: maybeResponse, maybeError: maybeError)
                }
                result = self.parse(response: response)
            } catch let error {
                response.maybeError = error
            }
            self.handleCompletion(urlRequest: urlRequest, response: response, result: result, method: method, duration: Date().timeIntervalSince1970 - firedTime, completionHandler: completionHandler)
        }
        if startImmediately { dataTask.resume() }
        return dataTask
    }
    
    internal func requestDownload(_ urlRequest: URLRequest, completionHandler: @escaping (URL?, Error?) -> Void) -> URLSessionDownloadTask? {
        let downloadTask = URLSession.shared.downloadTask(with: urlRequest) { (location, response, error) in
            do {
                try self.validateResponse(data: nil, httpResponse: response, maybeError: error)
            } catch let error {
                completionHandler(nil, error)
            }
            completionHandler(location, nil)
        }
        if startImmediately { downloadTask.resume() }
        return downloadTask
    }
    
    internal func requestUpload<ResultData: Decodable>(_ urlRequest: URLRequest, method: Method, data: Data?, completionHandler: @escaping (ResultData?, Error?) -> Void) -> URLSessionUploadTask? {
        let firedTime = Date().timeIntervalSince1970
        let uploadTask = session.uploadTask(with: urlRequest, from: data) { maybeData, maybeResponse, maybeError in
            let response = (method == .mock) ? MockResponse(maybeData, maybeResponse, maybeError) : Response(maybeData, maybeResponse, maybeError)
            var result: ResultData?
            do {
                if let responseValidateProvider = self.responseValidateProvider {
                    try responseValidateProvider(response.maybeData, response.maybeResponse, response.maybeError)
                } else {
                    try self.validateResponse(data: maybeData, httpResponse: maybeResponse, maybeError: maybeError)
                }
                result = self.parse(response: response)
            } catch let error {
                response.maybeError = error
            }
            self.handleCompletion(urlRequest: urlRequest, response: response, result: result, method: method, duration: Date().timeIntervalSince1970 - firedTime, completionHandler: completionHandler)
        }
        if startImmediately { uploadTask.resume() }
        return uploadTask
    }
    
    private func parse<ResultData: DataRepresentable>(response: Response) -> ResultData? {
        if let data = response.maybeData {
            return ResultData.fromData(data)
        }
        return nil
    }
    
    private func parse<ResultData: Decodable>(response: Response) -> ResultData? {
        do {
            if let data = response.maybeData {
                return try decoder.decode(ResultData.self, from: data)
            }
        } catch let parseError {
            response.maybeError = parseError
        }
        return nil
    }
    
    private func validateResponse(data: Data?, httpResponse: URLResponse?, maybeError: Error?) throws {
        if let httpResponse = httpResponse as? HTTPURLResponse, !httpResponse.isValidateStatusCode() {
            if let error = maybeError {
                throw error
            }
            throw HTTPClientResponseError.invalidStatusCode
        }
    }
}
