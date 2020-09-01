//
//  UIImage+Crop.swift
//  KPUI
//
//  Created by henry on 2018. 2. 6..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension Pay where Base: UIImage {
    public func crop(rect: CGRect) -> UIImage? {
        return base.crop(rect: rect)
    }
}

extension UIImage {

    internal func crop(rect: CGRect) -> UIImage? {
        let scale = UIScreen.main.scale
        let imageRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        guard let cropedCgImage = self.cgImage?.cropping(to: imageRect) else {
            return nil
        }
        
        return UIImage(cgImage: cropedCgImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
