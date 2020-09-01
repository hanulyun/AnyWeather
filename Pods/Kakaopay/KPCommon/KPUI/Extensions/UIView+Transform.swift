//
//  UIView+Transform.swift
//  Kakaopay
//
//  Created by logan.ysmanse on 02/08/2019.
//

import UIKit

extension Pay where Base: UIView {
    public func applyTransform(withScale scale: CGFloat, anchorPoint: CGPoint) {
        return base.applyTransform(withScale: scale, anchorPoint: anchorPoint)
    }
}

extension UIView {
    internal func applyTransform(withScale scale: CGFloat, anchorPoint: CGPoint) {
        layer.anchorPoint = anchorPoint
        let scale = scale != 0 ? scale : CGFloat.leastNonzeroMagnitude
        let xPadding = 1 / scale * (anchorPoint.x - 0.5) * bounds.width
        let yPadding = 1 / scale * (anchorPoint.y - 0.5) * bounds.height
        transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xPadding, y: yPadding)
    }
}
