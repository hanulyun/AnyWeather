//
//  WeatherModel.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension Main.Model {
    struct WeatherModel: Decodable {
        var id: Int?
        var city: String?
        var isGps: Bool? = false
        
        let lat: Double?
        let lon: Double?
        let timezone: String?
        var current: Current?
        let hourly: [Hourly]?
        let daily: [Daily]?
        
        struct Weather: Codable {
            let id: Int? // Condition Id
            let main: String? // Parameters. ex) Rain, Snow..
            let description: String? // Condition with text
            let icon: String? // Icon
        }
        
        struct Current: Codable {
            let dt: Double? // TimeStamp
            let sunrise: Double? // 일출
            let sunset: Double? // 일몰
            var temp: Double? // 기온
            let feels_like: Double? // 체감온도
            let pressure: Double? // 기압
            let humidity: Double? // 습도
            let uvi: Double? // 자외선지수
            let wind_deg: Double? // 바람 방향
            let wind_speed: Double? // 풍속
            let visibility: Double? // 가시거리 단위 m
            
            let weather: [Weather]?
        }
        
        struct Hourly: Codable {
            let dt: Double?
            let temp: Double?
            
            let weather: [Weather]?
        }
        
        struct Daily: Codable {
            let dt: Double?
            let temp: Temp?
            
            let weather: [Weather]?
            
            struct Temp: Codable {
                let min: Double?
                let max: Double?
            }
        }
    }
}

struct WeatherModel: Codable {
    var id: Int?
    var city: String?
    var isGps: Bool? = false
    
    let lat: Double?
    let lon: Double?
    let timezone: String?
    var current: Current?
    let hourly: [Hourly]?
    let daily: [Daily]?
    
    struct Weather: Codable {
        let id: Int? // Condition Id
        let main: String? // Parameters. ex) Rain, Snow..
        let description: String? // Condition with text
        let icon: String? // Icon
    }
    
    struct Current: Codable {
        let dt: Double? // TimeStamp
        let sunrise: Double? // 일출
        let sunset: Double? // 일몰
        var temp: Double? // 기온
        let feels_like: Double? // 체감온도
        let pressure: Double? // 기압
        let humidity: Double? // 습도
        let uvi: Double? // 자외선지수
        let wind_deg: Double? // 바람 방향
        let wind_speed: Double? // 풍속
        let visibility: Double? // 가시거리 단위 m
        
        let weather: [Weather]?
    }
    
    struct Hourly: Codable {
        let dt: Double?
        let temp: Double?
        
        let weather: [Weather]?
    }
    
    struct Daily: Codable {
        let dt: Double?
        let temp: Temp?
        
        let weather: [Weather]?
        
        struct Temp: Codable {
            let min: Double?
            let max: Double?
        }
    }
}
