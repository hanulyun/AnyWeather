//
//  ModalAnimator.swift
//  KPUI
//
//  Created by henry on 2018. 2. 21..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public enum TransitionState {
    case present
    case dismiss
}

/*
 concrete class that managing transition animation.
 */
open class TransitioningHandler: UIPercentDrivenInteractiveTransition {

    internal var transitionState: TransitionState = .present
    internal weak var viewController: UIViewController?
    internal var isInteractiveInternal = false // to support UIView animation based interactive.
    
    private var interactiveAnimator: UIViewPropertyAnimator?
    private weak var transitionContext: UIViewControllerContextTransitioning?
    
    public var isInteractive = false
    public var notifyBeginEndAppearanceTransition: Bool = false
    
    // default is false
    public var isEnabled: Bool = true {
        didSet {
            viewController?.transitioningDelegate = isEnabled ? self : nil
            viewController?.modalPresentationStyle = isEnabled ? .custom : .fullScreen
        }
    }

    override open func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard isInteractive else {
            return super.startInteractiveTransition(transitionContext)
        }
        
        interactiveAnimator = animator(using: transitionContext)
        self.transitionContext = transitionContext
    }
    
    open func updateAnimator(_ percentComplete: CGFloat) {
        interactiveAnimator?.fractionComplete = percentComplete
        transitionContext?.updateInteractiveTransition(percentComplete)
    }

    open func cancelAnimator(completion: @escaping (UIViewAnimatingPosition) -> Void) {
        transitionContext?.cancelInteractiveTransition()
        interactiveAnimator?.isReversed = true
        interactiveAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 1.0 - (interactiveAnimator?.fractionComplete ?? 0.0))
        interactiveAnimator?.addCompletion(completion)
    }
    
    open func finishAnimator(completion: @escaping (UIViewAnimatingPosition) -> Void) {
        transitionContext?.finishInteractiveTransition()
        interactiveAnimator?.isReversed = false
        interactiveAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0.0)
        interactiveAnimator?.addCompletion(completion)
    }

    internal init(on viewController: UIViewController) {
        super.init()
        self.viewController = viewController
    }
    
    // start manually 
    public func start(using transitionContext: UIViewControllerContextTransitioning) {
        self.animator(using: transitionContext).startAnimation()
    }
    
    // util
    internal func findViewControllerInContainerIfPossible(_ viewController: UIViewController?) -> UIViewController? {
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

extension TransitioningHandler: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isInteractiveInternal { (animator(using: transitionContext) as? InteractiveAnimator)?.startInterativeAnimation(context: transitionContext) }
        else { animator(using: transitionContext).startAnimation() }
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        isInteractive = false
    }
    
    @objc public func animator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        guard let transitionAnimatable = viewController as? TransitionAnimatable else {
            // don't animate when animator is nil
            let emptyAnimator = UIViewPropertyAnimator(duration: 0.0, curve: .linear, animations: nil)
            emptyAnimator.addCompletion { position in
                transitionContext.completeTransition(true)
            }
            return emptyAnimator
        }
        
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let fromNotifyBeginEndAppearanceTransition = (findViewControllerInContainerIfPossible(fromVC) as? TransitionAnimatable)?.transitioningHandler.notifyBeginEndAppearanceTransition ?? false
        let toNotifyBeginEndAppearanceTransition = (findViewControllerInContainerIfPossible(toVC) as? TransitionAnimatable)?.transitioningHandler.notifyBeginEndAppearanceTransition ?? false

        // viewWillAppear and viewWillDisappear
        if fromNotifyBeginEndAppearanceTransition { fromVC?.beginAppearanceTransition(false, animated: true) }
        if toNotifyBeginEndAppearanceTransition { toVC?.beginAppearanceTransition(true, animated: true) }
        
        let containerView = transitionContext.containerView
        switch transitionState {
        case .present:
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
            
            let animator = transitionAnimatable.presentTransitionAnimator(context: transitionContext)
            animator.addCompletion { position in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                if fromNotifyBeginEndAppearanceTransition && !transitionContext.transitionWasCancelled { fromVC?.endAppearanceTransition() }
                if toNotifyBeginEndAppearanceTransition && !transitionContext.transitionWasCancelled { toVC?.endAppearanceTransition() }
            }
            return animator
        case .dismiss:
            let animator = transitionAnimatable.dismissTransitionAnimator(context: transitionContext)
            animator.addCompletion { position in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                if fromNotifyBeginEndAppearanceTransition && !transitionContext.transitionWasCancelled { fromVC?.endAppearanceTransition() }
                if toNotifyBeginEndAppearanceTransition && !transitionContext.transitionWasCancelled { toVC?.endAppearanceTransition() }
            }
            return animator
        }
    }
}

extension TransitioningHandler: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let transitioningHandler = (viewController as? TransitionAnimatable)?.transitioningHandler, transitioningHandler.isEnabled else {
            return nil
        }
        
        transitioningHandler.transitionState = .present
        return transitioningHandler
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let transitioningHandler = (viewController as? TransitionAnimatable)?.transitioningHandler, transitioningHandler.isEnabled else {
            return nil
        }
        
        transitioningHandler.transitionState = .dismiss
        return transitioningHandler
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard let transitionAnimatable = viewController as? TransitionAnimatable else {
            return nil
        }
        
        let presentationController = transitionAnimatable.transitionAnimatorPresentationController(forPresented: presented, presenting: presenting, source: source)
        presentationController?.setTransitioningHandler(transitionAnimatable.transitioningHandler)
        return presentationController
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard isInteractive,
            let transitioningHandler = (viewController as? TransitionAnimatable)?.transitioningHandler, transitioningHandler.isEnabled else {
            return nil
        }
        
        transitioningHandler.transitionState = .present
        return transitioningHandler
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard isInteractive,
            let transitioningHandler = (viewController as? TransitionAnimatable)?.transitioningHandler, transitioningHandler.isEnabled else {
            return nil
        }
        
        transitioningHandler.transitionState = .dismiss
        return transitioningHandler
    }
}
