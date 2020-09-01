//
//  String+Validate.swift
//  KPCommon
//
//  Created by kali_company on 11/11/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == String {
    public var isValidEmail: Bool {
        return base.isValidEmail
    }
}

extension String {
    internal var isValidEmail: Bool {
        var isValid = true
        if self.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 {
            let emailRegex = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            if !emailTest.evaluate(with: self) {
                isValid = false
            }
        } else {
            isValid = false
        }
        
        return isValid
    }
}
