//
//  Date+Days.swift
//  KPCore
//
//  Created by Freddy on 2018. 7. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == Date {
    public static var today: Date { return Date() }
    public var yesterday: Date { return base.yesterday }
    public var tomorrow: Date { return base.tomorrow }
    public var startOfDay: Date { return base.startOfDay }
    public var endOfDay: Date { return base.endOfDay }
    public var startOfMonth: Date { return base.startOfMonth }
    public var endOfMonth: Date { return base.endOfMonth }
    public func previousMonth(ago month: Int) -> Date { return base.adding(.month, value: -month) }
    public func nextMonth(after month: Int) -> Date { return base.adding(.month, value: month) }
    public func daysFromNow() -> Int { return base.daysFromNow() }
    public func adding(_ component: Calendar.Component, value: Int) -> Date { return base.adding(component, value: value) }
    
    public static func date(from milliseconds: Int64) -> Date { return Date(milliseconds: milliseconds) }
    public static func date(from year: Int, month: Int, day: Int) -> Date { return Date(year: year, month: month, day: day) }
    
    public var millisecondsSince1970: Int64 { return base.millisecondsSince1970 }
    
    public var isLastDayInMonth: Bool { return base.isLastDayInMonth }
    public var isValidDate: Bool { return base.isValidDate }
    public func isSameDay(_ date: Date) -> Bool { return base.isSameDay(date) }
    public var isToday: Bool { return base.isToday }
    public var isPastDay: Bool { return base.isPastDay }
    public var isFutureDay: Bool { return base.isFutureDay }
    
    public func dday(_ endDate: Date) -> Int { return base.dday(endDate) }
    public func ddayComponents(_ endDate: Date) -> DateComponents { return base.ddayComponents(endDate) }
    
}

extension Date {
    
    internal var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    internal var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    internal var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    internal var endOfDay: Date {
        //        return Calendar.current.date(byAdding: .second, value: -1, to: self.tomorrow.startOfDay)! // 23:59:59:000
        return Date(milliseconds: self.tomorrow.startOfDay.millisecondsSince1970 - 1) // 23:59:59.999
    }
    
    internal var startOfMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    
    internal var endOfMonth: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        components.day = daysInMonth
        return Calendar.current.date(from: components)!
    }
    
    internal func daysFromNow() -> Int {
        return Calendar.current.dateComponents([.day], from: Date().startOfDay, to: self.startOfDay).day!
    }
    
    internal func adding(_ component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }
}

extension Date {
    // Timestamp
    internal init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    internal var millisecondsSince1970: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    internal init(year: Int, month: Int, day: Int)  {
        let calender = Calendar(identifier: .gregorian)
        var component = DateComponents()
        component.year = year
        component.month = month
        component.day = day
        self = calender.date(from: component)!
    }
}

extension Date {
    internal var daysInMonth: Int {
        return Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 0
    }
}

// day validate
extension Date {
    internal var isLastDayInMonth: Bool {
        return Calendar.current.isDate(self, inSameDayAs: endOfMonth)
    }
    
    internal var isValidDate: Bool {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        return components.isValidDate(in: Calendar.current)
    }
    
    internal func isSameDay(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    internal var isToday: Bool {
        return Date.pay.today.startOfDay.isSameDay(startOfDay)
    }
    
    internal var isPastDay: Bool {
        return Date.pay.today.startOfDay.dday(startOfDay) <= 0
    }
    
    internal var isFutureDay: Bool {
        return Date.pay.today.startOfDay.dday(startOfDay) > 0
    }
}

// dday
extension Date {
    internal func dday(_ endDate: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: endDate).day ?? 0
    }
    
    internal func ddayComponents(_ endDate: Date) -> DateComponents {
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: endDate)
        components.calendar = Calendar.current
        return components
    }
}
