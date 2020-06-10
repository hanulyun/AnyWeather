//
//  APIManager.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Foundation

class APIManager {
    
    var session: URLSession!
    
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
        }.resume()
    }
}
