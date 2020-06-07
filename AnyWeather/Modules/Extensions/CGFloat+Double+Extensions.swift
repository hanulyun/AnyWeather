//
//  CGFloat+Double+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension CGFloat {
    var adjusted: CGFloat {
        return self * (CommonSizes.screenWidth / 375)
    }
}

extension Double {
    var adjusted: CGFloat {
        return CGFloat(self) * (CommonSizes.screenWidth / 375)
    }
    
    func timestampToDate() -> Date {
        let date: Date = Date(timeIntervalSince1970: self)
        return date
    }
    
    func timestampToString(format: String) -> String {
        let date: Date = Date(timeIntervalSince1970: self)
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.amSymbol = "오전"
        dateFormatter.pmSymbol = "오후"
        dateFormatter.weekdaySymbols = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
        dateFormatter.timeZone = TimeZone.current
        
        let dateString: String = dateFormatter.string(from: date)
        
        return dateString
    }
}
