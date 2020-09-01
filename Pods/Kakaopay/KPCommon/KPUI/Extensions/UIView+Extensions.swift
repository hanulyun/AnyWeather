//
//  UIView+Extensions.swift
//  KPUI
//
//  Created by Freddy on 2018. 7. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension Pay where Base: UIView {
    public var parentViewController: UIViewController? {
        return base.parentViewController
    }
}

extension UIView {
    
    /// SwifterSwift: Get view's parent view controller
    internal var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
