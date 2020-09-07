//
//  CGFloat+Double+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension Double {
    
    func timestampToDate() -> Date {
        let date: Date = Date(timeIntervalSince1970: self)
        return date
    }
    
    func timestampToString(format: String) -> String {
        let date: Date = Date(timeIntervalSince1970: self)
        let dateFormatter: DateFormatter = .basicStyle(format: format)
        
        let dateString: String = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func calcWindDirection() -> String? {
        let direction: [String] = ["북", "북북동", "북동", "동북동", "동", "동남동", "서동", "서서동",
                                   "남", "남남서", "남서", "서남서", "서", "서북서", "북서", "북북서"]
        let index: Int = Int((self + 11.25) / 22.5)
        if index > direction.count - 1 {
            return nil
        } else {
            return direction[index]
        }
    }
    
    func calcTempUnit(to unit: TempUnit) -> Double {
        if unit == .celsius {
            return (self - 32) / 1.8
        } else {
            return self * 1.8 + 32
        }
    }
}
