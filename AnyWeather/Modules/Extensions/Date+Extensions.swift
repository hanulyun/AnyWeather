//
//  Date+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Foundation

extension Date {
    func dateToString(format: String, timeZone: String?) -> String {
        let dateFormatter: DateFormatter = .basicStyle(format: format)
        if let timeZone: String = timeZone {
            dateFormatter.timeZone = TimeZone(identifier: timeZone)
        }
        return dateFormatter.string(from: self)
    }
}

extension DateFormatter {
    static func basicStyle(format: String) -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.amSymbol = "오전"
        dateFormatter.pmSymbol = "오후"
        dateFormatter.weekdaySymbols = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
}
