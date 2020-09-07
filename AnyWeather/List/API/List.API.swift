//
//  List.API.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Kakaopay
import Promises

extension List.API {
    static func weather(lat: Double, lon: Double) -> Promise<Model.Weather> {
        let parameters: [String: Any] = [
            HTTPClient.ParamKey.lat.rawValue: String(lat),
            HTTPClient.ParamKey.lon.rawValue: String(lon),
            HTTPClient.ParamKey.appId.rawValue: HTTPClient.Parameters.apiKey,
            HTTPClient.ParamKey.lang.rawValue: HTTPClient.Parameters.lang,
            HTTPClient.ParamKey.units.rawValue: HTTPClient.Parameters.units
        ]
        return HTTPClient.pay.request(urlString: HTTPClient.Urls.oneCall, parameters: parameters)
    }
}
