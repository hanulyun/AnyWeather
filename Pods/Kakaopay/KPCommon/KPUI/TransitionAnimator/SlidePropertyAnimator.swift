//
//  SlidePropertyAnimator.swift
//  KPCommon
//
//  Created by kali_company on 19/02/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import UIKit

open class SlidePropertyAnimator: UIViewPropertyAnimator, InteractiveAnimator {
    public enum Direction {
        case left, right
    }
    
    weak var fromView: UIView?
    weak var toView: UIView?
    weak var context: UIViewControllerContextTransitioning?
    var direction = Direction.left
    
    convenience public init(context: UIViewControllerContextTransitioning,
                            state: TransitionState, direction: Direction, duration: TimeInterval = 0.1, curve: UIView.AnimationCurve = .easeInOut) {
        let toView = context.view(forKey: .to) ?? context.viewController(forKey: .to)?.view
        let fromView = context.view(forKey: .from) ?? context.viewController(forKey: .from)?.view
        self.init(toView: toView, fromView: fromView, state: state, direction: direction, duration: duration, curve: curve)
        self.context = context
    }
    
    convenience public init(toView maybeToView: UIView?, fromView maybeFromView: UIView?,
                            state: TransitionState, direction: Direction, duration: TimeInterval = 0.1, curve: UIView.AnimationCurve = .easeInOut) {
        self.init(duration: duration, curve: curve, animations: nil)
        guard let toView = maybeToView, let fromView = maybeFromView else {
            // makes empty animation to cancel.
            maybeToView?.alpha = 0.0
            self.addAnimations { maybeToView?.alpha = 1.0 }
            return
        }
        
        self.direction = direction
        self.toView = toView
        self.fromView = fromView

        toView.frame = CGRect(x: direction == .left ? toView.frame.width : -toView.frame.width, y: 0.0, width: toView.frame.width, height: toView.frame.height)
        self.addAnimations {
            toView.frame = fromView.frame
            fromView.frame = CGRect(x: direction == .left ? -fromView.frame.width : fromView.frame.width, y: 0.0, width: fromView.frame.width, height: fromView.frame.height)
        }
    }
    
    public func startInterativeAnimation(context: UIViewControllerContextTransitioning) {
        guard let toView = self.toView, let fromView = self.fromView else { return }
        
        let direction = self.direction
        
        toView.frame = CGRect(x: direction == .left ? toView.frame.width : -toView.frame.width, y: 0.0, width: toView.frame.width, height: toView.frame.height)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            toView.frame = fromView.frame
            fromView.frame = CGRect(x: direction == .left ? -fromView.frame.width : fromView.frame.width, y: 0.0, width: fromView.frame.width, height: fromView.frame.height)
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
}
