//
//  UIColor+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import Kakaopay

extension Pay where Base: UIColor {
    static func getWeatherColor(model: Main.Model.Weather?) -> UIColor {
        var color: UIColor = .darkGray
        var alpha: CGFloat = 1
        
        if let icon: String = model?.hourly?.first?.weather?.first?.icon, icon.contains("n") {
            alpha = 0.6
        }
        
        if let intId: Int = model?.current?.weather?.first?.id {
            switch intId {
            case 200..<299: // Thunderstorm
                color = UIColor.pay.rgba(r: 105, g: 105, b: 105, a: alpha)
            case 300..<399: // Drizzle
                color = UIColor.pay.rgba(r: 173, g: 216, b: 230, a: alpha)
            case 500..<599: // Rain
                color = UIColor.pay.rgba(r: 176, g: 196, b: 222, a: alpha)
            case 600..<699: // Snow
                color = UIColor.pay.rgba(r: 211, g: 211, b: 211, a: alpha)
            case 700..<799: // Atmosphere
                color = UIColor.pay.rgba(r: 112, g: 128, b: 144, a: alpha)
            case 800: // Clear
                color = UIColor.pay.rgba(r: 135, g: 206, b: 235, a: alpha)
            case 801..<899: // Clouds
                color = UIColor.pay.rgba(r: 70, g: 130, b: 180, a: alpha)
            default:
                break
            }
        }
        return color
    }
}
