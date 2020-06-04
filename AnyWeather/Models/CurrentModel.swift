//
//  CurrentModel.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

struct CurrentModel: Codable {
    var coord: Coord?
    var weather: [Weather]?
    var base: String? // Internal parameter
    var main: Main?
    var visibility: Double?
    var wind: Wind?
    var clouds: Clouds?
    var sys: Sys?
    var timezone: Double?
    var id: Int? // City Id
    var name: String?
    
    struct Coord: Codable {
        var lat: Double? // City geo location, latitude
        var lon: Double? // City geo location, longitude
    }
    
    struct Weather: Codable {
        var id: Int? // Condition Id
        var main: String? // Parameters. ex) Rain, Snow..
        var description: String? // Condition with text
        var icon: String? // Icon
    }
    
    struct Main: Codable {
        var temp: Double? // Temperature
        var feels_like: Double? // 체감온도
        var temp_min: Double? // 최저온도
        var temp_max: Double? // 최고온도
        var pressure: Double? // 기압 hPa
        var humidity: Double? // 습도 %
    }
    
    struct Wind: Codable {
        var speed: Double? // 풍속
        var deg: Double? // 바람 각도, ex) 350 이렇게 나오면 서남서 등등.. 으로 표현해야 함.
    }
    
    struct Clouds: Codable {
        var all: Int?
    }
    
    struct Sys: Codable {
        var type: Int?
        var id: Int?
        var message: Double?
        var country: String?
        var sunrise: Double? // 일출
        var sunset: Double? // 일몰
    }
}
