//
//  ForecastModel.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

struct ForecastModel: Codable {
    var message: Int?
    var cnt: Int?
    var list: [List]?
    var city: City?
    
    struct List: Codable {
        var dt: Double?
        var main: CurrentModel.Main?
        var weather: [CurrentModel.Weather]?
        var clouds: CurrentModel.Clouds?
        var wind: CurrentModel.Wind?
        var sys: Sys?
        var dt_txt: String?
    }
    
    struct Sys: Codable {
        var sys: String?
    }
    
    struct City: Codable {
        var id: Int?
        var name: String?
        var coord: CurrentModel.Coord?
        var country: String?
        var timezone: Double?
        var sunrise: Double?
        var sunset: Double?
    }
}
