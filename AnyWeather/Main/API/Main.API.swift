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
    static func weather(lat: String, lon: String) -> Promise<Model.WeatherModel> {
        let parameters: [String: Any] = [
            HTTPClient.ParamKey.lat.rawValue: String(lat),
            HTTPClient.ParamKey.lon.rawValue: String(lon)
        ]
        return HTTPClient.pay.request(urlString: HTTPClient.Urls.oneCall, parameters: parameters)
    }
}
