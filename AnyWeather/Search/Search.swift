//
//  Search.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Kakaopay

protocol SearchNamespace {
    typealias Model = Search.Model
}

struct Search: Namespace {
    static func initialize() { }
    struct Model {
        typealias Weather = Main.Model.Weather
        typealias WeatherItem = Main.Model.CoreWeatherItem
    }
}
