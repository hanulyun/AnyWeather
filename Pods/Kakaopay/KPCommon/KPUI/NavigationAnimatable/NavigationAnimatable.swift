//
//  TransitionAnimatable.swift
//  KPUI
//
//  Created by henry on 2018. 2. 21..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public protocol NavigationAnimatable: NSObjectProtocol {
    var navigationHandler: NavigationTransitioningHandler { get }
    var navigationDimmedView: UIView? { get }
    
    func shouldStartTransitionAnimation(from: UIViewController, to: UIViewController, state: TransitionState) -> Bool
    func pushTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator
    func popTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator
}

private var navigationHandlerAssociatedObjectKey: Void?
extension NavigationAnimatable where Self: UINavigationController {

    public var navigationHandler: NavigationTransitioningHandler {
        guard let handler = objc_getAssociatedObject(self, &navigationHandlerAssociatedObjectKey) as? NavigationTransitioningHandler else {
            let newHandler = NavigationTransitioningHandler(on: self)
            objc_setAssociatedObject(self, &navigationHandlerAssociatedObjectKey, newHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newHandler
        }
        return handler
    }
}
