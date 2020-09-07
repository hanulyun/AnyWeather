//
//  HTTPClient+Url.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Kakaopay

extension HTTPClient {
    struct Urls {
        static let baseProtocol: String = "https://"
        static let baseUrl: String = "api.openweathermap.org/data/2.5"
        static let oneCall: String = "\(baseProtocol)\(baseUrl)/onecall"
        static let icon: String = "\(Urls.baseProtocol)api.openweathermap.org/img/w/"
    }

    struct Parameters {
        static let apiKey: String = "ae7f17a003676980a4b335cac9959dd0"
        static let lang: String = "kr"
        static let units: String = "metric"
    }

    public enum ParamKey: String {
        case appId = "appid"
        case city = "q"
        case lat = "lat"
        case lon = "lon"
        case lang = "lang"
        case units = "units"
    }
}
