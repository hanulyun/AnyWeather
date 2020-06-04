//
//  UIFont+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension UIFont {
    static func font(_ fontSet: FontSet) -> UIFont {
        return fontSet.rawValue
    }
}
