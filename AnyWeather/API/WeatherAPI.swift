//
//  WeatherAPI.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Foundation

struct Urls {
    static let base: String = "https://api.openweathermap.org/data/2.5"
    static let current: String = "/weather"
    static let forecast: String = "/forecast"
    static let several: String = ""
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
    case cnt = "cnt"
    case units = "units"
}
