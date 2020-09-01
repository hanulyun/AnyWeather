//
//  String+Localize.swift
//  KPCore
//
//  Created by kali_company on 2018. 4. 13..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == String {
    public func localized(with comment: String? = nil) -> String {
        return base.localized(with: comment)
    }
}

extension String {
    internal func localized(with comment: String? = nil) -> String {
        let userComment = comment ?? ""
        return NSLocalizedString(self, comment:userComment)
    }
}
