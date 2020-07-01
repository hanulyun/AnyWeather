//
//  WeatherModel.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

struct WeatherModel: Codable {
    var id: Int?
    var city: String?
    var isGps: Bool? = false
    
    var lat: Double?
    var lon: Double?
    var timezone: String?
    var current: Current?
    var hourly: [Hourly]?
    var daily: [Daily]?
    
    struct Weather: Codable {
        var id: Int? // Condition Id
        var main: String? // Parameters. ex) Rain, Snow..
        var description: String? // Condition with text
        var icon: String? // Icon
    }
    
    struct Current: Codable {
        var dt: Double? // TimeStamp
        var sunrise: Double? // 일출
        var sunset: Double? // 일몰
        var temp: Double? // 기온
        var feelsLike: Double? // 체감온도
        var pressure: Double? // 기압
        var humidity: Double? // 습도
        var uvi: Double? // 자외선지수
        var windDeg: Double? // 바람 방향
        var windSpeed: Double? // 풍속
        var visibility: Double? // 가시거리 단위 m
        
        var weather: [Weather]?
    }
    
    struct Hourly: Codable {
        var dt: Double?
        var temp: Double?
        
        var weather: [Weather]?
    }
    
    struct Daily: Codable {
        var dt: Double?
        var temp: Temp?
        
        var weather: [Weather]?
        
        struct Temp: Codable {
            var min: Double?
            var max: Double?
        }
    }
}
