//
//  APIManager.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Foundation
import Promises

enum SessionError: Error {
    case invalidUrl
    case serverError
    case noData
    case failedToParse
    case unknowned
}

class APIManager {
    
    static let shared: APIManager = APIManager()
    
    var session: URLSession!
    
    func request<T: Decodable>(_ type: T.Type, url: String, param: [String: Any]) -> Promise<T> {
        return setComponentUrl(url, param: param).then(sessionDataTask).then(parseModel)
            .catch { error in
                Log.debug(error.localizedDescription)
        }
    }
    
    func setComponentUrl(_ url: String, param: [String: Any]) -> Promise<URL> {
        let promise: Promise<URL> = Promise<URL>.pending()
        
        guard var component: URLComponents = URLComponents(string: Urls.baseProtocol + Urls.baseUrl + url)
            else { promise.reject(SessionError.invalidUrl); return promise }
        
        var param: [String: Any] = param
        param[ParamKey.appId.rawValue] = Parameters.apiKey
        param[ParamKey.lang.rawValue] = Parameters.lang
        param[ParamKey.units.rawValue] = Parameters.units
        component.queryItems = param.map { key, value in
            URLQueryItem(name: key, value: value as? String)
        }
        
        guard let url: URL = component.url else { promise.reject(SessionError.invalidUrl); return promise }
        
        promise.fulfill(url)
        
        return promise
    }
    
    private func sessionDataTask(_ url: URL) -> Promise<(Data?, URLResponse?)> {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        if session == nil {
            session = URLSession(configuration: config)
        }
        return wrap { self.session.dataTask(with: url, completionHandler: $0).resume() }
    }
    
    private func parseModel<T: Decodable>(_ data: Data?, response: URLResponse?) throws -> Promise<T> {
        let promise: Promise<T> = Promise<T>.pending()
        
        guard let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode) else {
                throw SessionError.serverError
        }
        
        guard let data = data else { throw SessionError.noData }
        
        let decoder: JSONDecoder = JSONDecoder()
        if let model: T = try? decoder.decode(T.self, from: data) {
            promise.fulfill(model)
        } else {
            throw SessionError.failedToParse
        }
        
        return promise
    }
    
    func request<T: Decodable>(_ type: T.Type, url: String, param: [String: Any],
                                      result: @escaping ((T?, Error?) -> Void)) {
        guard var component: URLComponents = URLComponents(string: Urls.baseProtocol + Urls.baseUrl + url) else {
            Log.debug("Failed to load UrlComponents: \(url)"); return
        }
        
        var param: [String: Any] = param
        param[ParamKey.appId.rawValue] = Parameters.apiKey
        param[ParamKey.lang.rawValue] = Parameters.lang
        param[ParamKey.units.rawValue] = Parameters.units
        component.queryItems = param.map { key, value in
            URLQueryItem(name: key, value: value as? String)
        }
        
        guard let url: URL = component.url else { Log.debug("Failed to load Url"); return }
        
        if session == nil {
            session = URLSession.shared
        }
        
        session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    result(nil, error)
                    return
                }
                
                guard let data = data else {
                    result(nil, NSError(domain: "No Data", code: 777, userInfo: nil))
                    return
                }
                
                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let model = try decoder.decode(T.self, from: data)
                    result(model, nil)
                } catch let error {
                    result(nil, error)
                }
            }
        }.resume()
    }
}
