//
//  Date+Formatter.swift
//  KPCore
//
//  Created by kali_company on 2018. 5. 12..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == Date {
    public func datetimeString() -> String {
        return base.datetimeString()
    }
    
    public func dateString() -> String {
        return base.dateString()
    }
    
    public func timeString() -> String {
        return base.timeString()
    }
    
    public func formattedString(format: String) -> String {
        return base.formattedString(format: format)
    }
}

extension Date {
    internal func datetimeString() -> String {
        return formattedString(format: "yyyy.MM.dd HH:mm:ss")
    }
    
    internal func dateString() -> String {
        return formattedString(format: "yyyy.MM.dd")
    }
    
    internal func timeString() -> String {
        return formattedString(format: "hh:mm:ss")
    }
    
    internal func formattedString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
