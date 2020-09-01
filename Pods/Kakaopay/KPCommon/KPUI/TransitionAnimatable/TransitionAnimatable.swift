//
//  TransitionAnimatable.swift
//  KPUI
//
//  Created by henry on 2018. 2. 21..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public protocol TransitionAnimatable: TransitionHandleable {
    func presentTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator
    func dismissTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator
    
    // optional (default is nil)
    func transitionAnimatorPresentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> (UIPresentationController & TransitionHandleable)?
}

extension TransitionAnimatable where Self: UIViewController {
    
    public func transitionAnimatorPresentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> (UIPresentationController & TransitionHandleable)? {
        return nil
    }
}

