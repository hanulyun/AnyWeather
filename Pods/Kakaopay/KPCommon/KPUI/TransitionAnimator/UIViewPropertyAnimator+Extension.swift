//
//  UIViewPropertyAnimator+Extension.swift
//  PayApp
//
//  Created by henry on 01/07/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import UIKit

extension UIViewPropertyAnimator {
    
    public convenience init(duration: TimeInterval = 0.3, curve: UIView.AnimationCurve? = .easeInOut, dampingRatio: CGFloat? = nil) {
        if let dampingRatio = dampingRatio {
            self.init(duration: duration, dampingRatio: dampingRatio, animations: nil)
        } else if let curve = curve {
            self.init(duration: duration, curve: curve, animations: nil)
        } else {
            self.init(duration: duration, curve: .easeInOut, animations: nil)
        }
    }
}

extension Pay where Base: UIViewPropertyAnimator {
    
    public func findViewControllerInContainerIfPossible(_ viewController: UIViewController) -> UIViewController {
        var contentViewController = viewController
        if let navigationController = viewController as? UINavigationController, let topViewController = navigationController.topViewController {
            contentViewController = topViewController
        } else if let tabBarController = viewController as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
            contentViewController = selectedViewController
        } else {
            return contentViewController
        }
        return findViewControllerInContainerIfPossible(contentViewController)
    }
}
