//
//  String+Date.swift
//  1PasswordExtension
//
//  Created by Lyman.j on 24/04/2019.
//

import Foundation


extension Pay where Base == String {
    public func toDate(format: String) -> Date? {
        return base.transferToDate(format: format)
    }
}



extension String {
    internal func transferToDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: self)
    }
}
