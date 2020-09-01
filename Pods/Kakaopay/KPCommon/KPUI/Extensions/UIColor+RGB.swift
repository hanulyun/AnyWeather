//
//  UIColor+RGB.swift
//  KPUI
//
//  Created by Freddy on 2018. 4. 17..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base: UIColor {
    public static func rgb(r: UInt8, g: UInt8, b: UInt8) -> UIColor {
        return UIColor(red: r, green: g, blue: b, transparency: 1)
    }
        
    public static func rgba(r: UInt8, g: UInt8, b: UInt8, a: CGFloat) -> UIColor {
        return UIColor(red: r, green: g, blue: b, transparency: a)
    }
}

extension UIColor {
    internal convenience init(red: UInt8, green: UInt8, blue: UInt8, transparency: CGFloat = 1) {
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
}
