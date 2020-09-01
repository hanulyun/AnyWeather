//
//  PropertyAnimatorTransitionContext.swift
//  AloeStackView
//
//  Created by henry on 02/07/2019.
//

import UIKit

open class PropertyAnimatorTransitionContext: NSObject, UIViewControllerContextTransitioning {
    
    private weak var fromViewController: UIViewController!
    private weak var toViewController: UIViewController!
    private weak var onView: UIView!
    
    private override init() {}
    init(from: UIViewController, to: UIViewController, onView: UIView? = nil) {
        super.init()
        self.fromViewController = from
        self.toViewController = to
        self.onView = onView ?? from.view
    }
    
    open var containerView: UIView { return onView }
    open var isAnimated: Bool { return true }
    open var isInteractive: Bool { return false }
    
    open var transitionWasCancelled: Bool { return false }
    
    open var presentationStyle: UIModalPresentationStyle {
        return .custom
    }
    
    open func updateInteractiveTransition(_ percentComplete: CGFloat) {}
    open func finishInteractiveTransition() {}
    open func cancelInteractiveTransition() {}
    open func pauseInteractiveTransition() {}
    open func completeTransition(_ didComplete: Bool) {}
    
    open func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        if key == .from {
            return fromViewController
        } else {
            return toViewController
        }
    }
    
    open func view(forKey key: UITransitionContextViewKey) -> UIView? {
        if key == .from {
            return fromViewController.view
        } else {
            return toViewController.view
        }
    }
    
    open var targetTransform: CGAffineTransform { return CGAffineTransform() }
    open func initialFrame(for vc: UIViewController) -> CGRect { return vc.view.frame }
    open func finalFrame(for vc: UIViewController) -> CGRect { return vc.view.frame }
}
