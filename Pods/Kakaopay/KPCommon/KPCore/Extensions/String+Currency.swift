//
//  String+Currency.swift
//  KPCore
//
//  Created by kali_company on 2018. 5. 4..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == String {
    public func amount() -> Int {
        return base.amount()
    }
    
    public func absString() -> String {
        return base.removeSign()
    }
}

extension String {
    internal func amount() -> Int {
        let amountString = self.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ".", with: "")
        return Int(amountString) ?? 0
    }
    
    internal func removeSign() -> String {
        let pureString = self.replacingOccurrences(of: "+", with: "").self.replacingOccurrences(of: "-", with: "")
        return pureString
    }
}
