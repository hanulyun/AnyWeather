//
//  HTTPClient+Session.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Kakaopay
import Promises

extension HTTPClient {
    func request<ResponseData: Decodable>(
        urlString: String, parameters: [String: Any]? = nil,
        parameterEncoding: URLRequest.ParameterEncoding = .form) -> Promise<ResponseData> {
        
        return Promise<ResponseData> { fulfill, reject in
            self.request(urlString: urlString, method: .get, headers: nil, parameters: parameters,
                         parameterEncoding: parameterEncoding) { (data: ResponseData?, error) in
                if let error = error { return reject(error) }
                fulfill(data!)
            }
        }.catch { error in
            Log.debug("Error: \(error as? HTTPClient.SessionError)")
        }
    }
}
