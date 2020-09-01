//
//  ModalAnimator.swift
//  KPUI
//
//  Created by henry on 2018. 2. 21..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

/*
 concrete class that managing transition animation.
 */
open class NavigationTransitioningHandler: TransitioningHandler {

    internal weak var navigationController: UINavigationController? {
        return viewController as? UINavigationController
    }
    
    // default is false
    override public var isEnabled: Bool {
        didSet {
            navigationController?.delegate = isEnabled ? self : nil
        }
    }
}

extension UIView {
    fileprivate func hasChild(_ view: UIView) -> Bool {
        if self === view {
            return true
        }

        for subview in self.subviews {
            if subview.hasChild(view) {
                return true
            }
        }
        return false
    }
}

extension NavigationTransitioningHandler {
    override public func animator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        guard let navigationAnimatable = viewController as? NavigationAnimatable else {
            
            // don't animate when animator is nil
            let emptyAnimator = UIViewPropertyAnimator(duration: 0.0, curve: .linear, animations: nil)
            emptyAnimator.addCompletion { position in
                transitionContext.completeTransition(true)
            }
            return emptyAnimator
        }
        
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let fromNotifyBeginEndAppearanceTransition = (findViewControllerInContainerIfPossible(fromVC) as? NavigationAnimatable)?.navigationHandler.notifyBeginEndAppearanceTransition ?? false
        let toNotifyBeginEndAppearanceTransition = (findViewControllerInContainerIfPossible(toVC) as? NavigationAnimatable)?.navigationHandler.notifyBeginEndAppearanceTransition ?? false

        // viewWillAppear and viewWillDisappear
        if fromNotifyBeginEndAppearanceTransition { fromVC?.beginAppearanceTransition(false, animated: true) }
        if toNotifyBeginEndAppearanceTransition { toVC?.beginAppearanceTransition(true, animated: true) }
        
        let containerView = transitionContext.containerView
        if let toView = transitionContext.view(forKey: .to) {
            if let fromView = transitionContext.view(forKey: .from), fromView.hasChild(containerView) == false {
                fromView.frame = containerView.frame
                fromView.frame.origin = CGPoint.zero
                containerView.addSubview(fromView)
            }
            toView.frame = containerView.frame
            toView.frame.origin = CGPoint.zero
            toView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(toView)
        }
        
        let animator = (navigationAnimatable.navigationHandler.transitionState == .present) ?
            navigationAnimatable.pushTransitionAnimator(context: transitionContext) :
            navigationAnimatable.popTransitionAnimator(context: transitionContext)
        animator.addCompletion { position in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            if fromNotifyBeginEndAppearanceTransition { fromVC?.endAppearanceTransition() }
            if toNotifyBeginEndAppearanceTransition { toVC?.endAppearanceTransition() }
        }
        return animator
    }
}

extension NavigationTransitioningHandler: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let navigationAnimatable = (viewController as? NavigationAnimatable), navigationAnimatable.navigationHandler.isEnabled else {
            return nil
        }

        let state: TransitionState = (operation == .push) ? .present : .dismiss
        if navigationAnimatable.shouldStartTransitionAnimation(from: fromVC, to: toVC, state: state) {
            navigationAnimatable.navigationHandler.transitionState = (operation == .push) ? .present : .dismiss
            return navigationAnimatable.navigationHandler
        }
        return nil
    }
}
