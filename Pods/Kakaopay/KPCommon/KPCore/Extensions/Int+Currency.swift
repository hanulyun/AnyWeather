//
//  Int+Currency.swift
//  KPCore
//
//  Created by kali_company on 2018. 5. 8..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == Int {
    public func commaString() -> String {
        return base.commaString()
    }
    
    public func commaWonString() -> String {
        return base.commaWonString()
    }
    
    public func signCommaWonString() -> String {
        return base.signCommaWonString()
    }
    
    public func tenThousandString() -> String {
        return base.tenThousandString()
    }
    
    public func moneyUnitString() -> String {
        return base.moneyUnitString()
    }
}

extension Int {
    internal func commaString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = Locale(identifier: "ko_KR")
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
    internal func commaWonString() -> String {
        let comma = self.commaString()
        if comma.isEmpty == false {
            return comma+"원"
        }
        return ""
    }
    
    internal func signCommaWonString() -> String {
        return self > 0 ? ("+" + self.commaWonString()) : self.commaWonString()
    }
    
    internal func tenThousandString() -> String {
        let divideByTenThousand = self / 10000
        return "\(divideByTenThousand)만"
    }
    
    internal func moneyUnitString() -> String {
        let thousand = self / 1000
        let tenThousand = self / 10000
        let tenThousandRest = self % 10000 / 1000
        
        if thousand == 0 {
            return "\(self)원"
        } else if tenThousand == 0 {
            return "\(tenThousandRest)천원"
        } else if tenThousandRest == 0 {
            return "\(tenThousand)만원"
        } else {
            return "\(tenThousand)만 \(tenThousandRest)천원"
        }
    }
}
