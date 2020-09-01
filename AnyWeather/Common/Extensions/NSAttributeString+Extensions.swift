//
//  NSAttributeString+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    @discardableResult func custom(_ text: String?,
                                   color: UIColor, font: UIFont) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: font]
        let string = NSMutableAttributedString(string: text ?? "", attributes: attrs)
        append(string)

        return self
    }
}

