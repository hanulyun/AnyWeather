//
//  APIManager.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Foundation

class APIManager {
    static let shared: APIManager = APIManager()
    
    func request<T: Decodable>(_ type: T.Type, url: String, param: [String: Any],
                               result: @escaping ((T) -> Void)) {
        guard var component: URLComponents = URLComponents(string: Urls.base + url) else {
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
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let res: HTTPURLResponse = response as? HTTPURLResponse {
                Log.debug("url: \(url), status: \(res.statusCode)")
                
                if let data: Data = data,
                    (200 ..< 300) ~= res.statusCode,
                    error == nil {
                    
                    let jsonString = String(decoding: data, as: UTF8.self)
                    let dict = jsonString.convertToDictionary()
                    Log.debug("dict: \(String(describing: dict))")
                    
                    let decoder: JSONDecoder = JSONDecoder()
                    guard let loaded = try? decoder.decode(T.self, from: data)
                        else { Log.debug("Failed to decode data"); return }
                    
                    result(loaded)
                } else {
                    Log.debug("error: \(String(describing: error?.localizedDescription))")
                }
            }
        }
        task.resume()
    }
}
