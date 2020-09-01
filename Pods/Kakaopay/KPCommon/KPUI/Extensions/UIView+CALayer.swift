//
//  UIView+CALayer.swift
//  KPUI
//
//  Created by Freddy on 2018. 5. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension Pay where Base: UIView {
    public func addShadow(x: CGFloat = 0, y: CGFloat = 5, blur: CGFloat = 10, color: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08)) {
        base.addShadow(x: x, y: y, blur: blur, color: color)
    }
    
    public func createGradientLayer(frame: CGRect? = nil, colors: [Any]? = [UIColor.pay.rgb(r: 73, g: 80, b: 87).cgColor, UIColor.pay.rgb(r: 52, g: 58, b: 64).cgColor]) {
        base.createGradientLayer(frame: frame, colors: colors)
    }
}


extension UIView {
    internal func addShadow(x: CGFloat = 0, y: CGFloat = 5, blur: CGFloat = 10, color: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08)) {
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 1
    }
    
    internal func createGradientLayer(frame: CGRect? = nil, colors: [Any]? = [UIColor.pay.rgb(r: 73, g: 80, b: 87).cgColor, UIColor.pay.rgb(r: 52, g: 58, b: 64).cgColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame ?? self.bounds
        gradientLayer.colors = colors
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
