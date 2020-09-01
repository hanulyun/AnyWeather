//
//  UIColor+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func color(_ set: ColorSet) -> UIColor {
        return set.rawValue
    }
    
    static func getWeatherColor(model: WeatherModel?) -> UIColor {
        var color: UIColor = .darkGray
        var alpha: CGFloat = 1
        
        if let icon: String = model?.hourly?.first?.weather?.first?.icon, icon.contains("n") {
            alpha = 0.6
        }
        
        if let intId: Int = model?.current?.weather?.first?.id {
            switch intId {
            case 200..<299: // Thunderstorm
                color = .getRGBColor(r: 105, g: 105, b: 105, alpha: alpha)
            case 300..<399: // Drizzle
                color = .getRGBColor(r: 173, g: 216, b: 230, alpha: alpha)
            case 500..<599: // Rain
                color = .getRGBColor(r: 176, g: 196, b: 222, alpha: alpha)
            case 600..<699: // Snow
                color = .getRGBColor(r: 211, g: 211, b: 211, alpha: alpha)
            case 700..<799: // Atmosphere
                color = .getRGBColor(r: 112, g: 128, b: 144, alpha: alpha)
            case 800: // Clear
                color = .getRGBColor(r: 135, g: 206, b: 235, alpha: alpha)
            case 801..<899: // Clouds
                color = .getRGBColor(r: 70, g: 130, b: 180, alpha: alpha)
            default:
                break
            }
        }
        return color
    }
    
    static func getRGBColor(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: alpha)
    }
}
