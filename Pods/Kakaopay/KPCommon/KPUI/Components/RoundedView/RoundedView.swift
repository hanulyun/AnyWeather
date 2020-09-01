//
//  RoundedView.swift
//  Kakaopay
//
//  Created by kali.forever on 04/12/2019.
//

import UIKit

//@IBDesignable
public class RoundedView: UIView {
    
    @IBInspectable public var leftTop: Bool = false
    @IBInspectable public var rightTop: Bool = false
    @IBInspectable public var leftBottom: Bool = false
    @IBInspectable public var rightBottom: Bool = false
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupRound()
    }
    
    public func setupRound() {
        if leftTop, !layer.maskedCorners.contains(.layerMinXMinYCorner) {
            layer.maskedCorners.insert(.layerMinXMinYCorner)
        } else if !leftTop, layer.maskedCorners.contains(.layerMinXMinYCorner) {
            layer.maskedCorners.remove(.layerMinXMinYCorner)
        }
        if rightTop, !layer.maskedCorners.contains(.layerMaxXMinYCorner) {
            layer.maskedCorners.insert(.layerMaxXMinYCorner)
        } else if !rightTop, layer.maskedCorners.contains(.layerMaxXMinYCorner) {
            layer.maskedCorners.remove(.layerMaxXMinYCorner)
        }
        if leftBottom, !layer.maskedCorners.contains(.layerMinXMaxYCorner) {
            layer.maskedCorners.insert(.layerMinXMaxYCorner)
        } else if !leftBottom, layer.maskedCorners.contains(.layerMinXMaxYCorner) {
            layer.maskedCorners.remove(.layerMinXMaxYCorner)
        }
        if rightBottom, !layer.maskedCorners.contains(.layerMaxXMaxYCorner) {
            layer.maskedCorners.insert(.layerMaxXMaxYCorner)
        } else if !rightBottom, layer.maskedCorners.contains(.layerMaxXMaxYCorner) {
            layer.maskedCorners.remove(.layerMaxXMaxYCorner)
        }
    }
}
