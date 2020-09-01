//
//  UIImage+Crop.swift
//  KPUI
//
//  Created by henry on 2018. 2. 6..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension Pay where Base: UIImage {
    public func extractColor(at point: CGPoint = CGPoint.zero) -> UIColor? {
        return base.extractColor(at: point)
    }
}

extension UIImage {
    
    internal func extractColor(at point: CGPoint = CGPoint.zero) -> UIColor? {
        guard let cfData = self.cgImage?.dataProvider?.data, let data = CFDataGetBytePtr(cfData) else {
            return nil
        }
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4
        let a = CGFloat(data[pixelInfo + 3]) / 0xff
        let r = CGFloat(data[pixelInfo + 2]) / 0xff
        let g = CGFloat(data[pixelInfo + 1]) / 0xff
        let b = CGFloat(data[pixelInfo + 0]) / 0xff

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

