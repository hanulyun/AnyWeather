//
//  Main.API.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Kakaopay
import Promises

extension Main.API {
    static func weather(lat: String, lon: String) -> Promise<Model.Weather> {
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
