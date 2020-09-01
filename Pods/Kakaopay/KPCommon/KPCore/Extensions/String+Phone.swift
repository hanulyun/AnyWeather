//
//  String+Phone.swift
//  KPCommon
//
//  Created by kali_company on 26/02/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == String {
    public var formattedPhone: String {
        return base.formattedPhone()
    }
}

extension String {
    internal func formattedPhone() -> String {
        guard count == 10 || count == 11 else { return self }
        
        var original = self
        original.insert("-", at: original.index(original.endIndex, offsetBy: -4))
        original.insert("-", at: original.index(original.startIndex, offsetBy: 3))
        
        return original
    }
}
