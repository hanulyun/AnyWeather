//
//  ContainerContextTransitioning.swift
//  KPUI
//
//  Created by henry on 2018. 2. 27..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

internal class ContainerTransitionContext: NSObject, UIViewControllerContextTransitioning {
    
    private weak var fromViewController: UIViewController!
    private weak var toViewController: UIViewController!
    private weak var onView: UIView!
    private var completion: ((Bool) -> Void)!
    
    private override init() {}
    init(from: UIViewController, to: UIViewController, on: UIView, completion: @escaping (Bool) -> Void) {
        super.init()
        self.fromViewController = from
        self.toViewController = to
        self.onView = on
        self.completion = completion
    }
    
    public var containerView: UIView { return onView }
    public var isAnimated: Bool { return true }
    public var isInteractive: Bool { return false }
    
    public var transitionWasCancelled: Bool { return false }
    
    public var presentationStyle: UIModalPresentationStyle {
        return .custom
    }
    
    // Container does not supports interactive transition.
    public func updateInteractiveTransition(_ percentComplete: CGFloat) {}
    public func finishInteractiveTransition() {}
    public func cancelInteractiveTransition() {}
    public func pauseInteractiveTransition() {}
    
    public func completeTransition(_ didComplete: Bool) {
        completion(didComplete)
    }
    
    public func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        if key == .from {
            return fromViewController
        } else {
            return toViewController
        }
    }
    
    public func view(forKey key: UITransitionContextViewKey) -> UIView? {
        if key == .from {
            return fromViewController.view
        } else {
            return toViewController.view
        }
    }
    
    public var targetTransform: CGAffineTransform { return CGAffineTransform() }
    public func initialFrame(for vc: UIViewController) -> CGRect { return vc.view.frame }
    public func finalFrame(for vc: UIViewController) -> CGRect { return vc.view.frame }
    
}

