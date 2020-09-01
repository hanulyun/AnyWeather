//
//  UIViewPropertyAnimator+Convenience.swift
//  KPUI
//
//  Created by Miller on 2018. 5. 23..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension Pay where Base: UIViewPropertyAnimator {
    @discardableResult
    public static func runningPropertyAnimator(withDuration duration: TimeInterval,
                                               delay: TimeInterval,
                                               curve: UIView.AnimationCurve,
                                               userInteractionEnabled: Bool = false,
                                               animations: @escaping () -> Swift.Void,
                                               completion: ((UIViewAnimatingPosition) -> Swift.Void)? = nil) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: delay, curve: curve, userInteractionEnabled: userInteractionEnabled, animations: animations, completion: completion)
    }
    
    @discardableResult
    public static func runningPropertyAnimator(withDuration duration: TimeInterval,
                                               delay: TimeInterval,
                                               dampingRatio: CGFloat,
                                               userInteractionEnabled: Bool = false,
                                               animations: @escaping () -> Swift.Void,
                                               completion: ((UIViewAnimatingPosition) -> Swift.Void)? = nil) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: delay, dampingRatio: dampingRatio, userInteractionEnabled: userInteractionEnabled, animations: animations, completion: completion)
    }
}

extension UIViewPropertyAnimator {
    @discardableResult
    internal class func runningPropertyAnimator(withDuration duration: TimeInterval,
                                                delay: TimeInterval,
                                                dampingRatio: CGFloat,
                                                userInteractionEnabled: Bool = false,
                                                animations: @escaping () -> Swift.Void,
                                                completion: ((UIViewAnimatingPosition) -> Swift.Void)? = nil) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: dampingRatio, animations: animations)
        animator.isUserInteractionEnabled = userInteractionEnabled
        if let completion = completion {
            animator.addCompletion(completion)
        }
        animator.startAnimation(afterDelay: delay)
        return animator
    }
    
    @discardableResult
    internal class func runningPropertyAnimator(withDuration duration: TimeInterval,
                                                delay: TimeInterval,
                                                curve: UIView.AnimationCurve,
                                                userInteractionEnabled: Bool = false,
                                                animations: @escaping () -> Swift.Void,
                                                completion: ((UIViewAnimatingPosition) -> Swift.Void)? = nil) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve, animations: animations)
        animator.isUserInteractionEnabled = userInteractionEnabled
        if let completion = completion {
            animator.addCompletion(completion)
        }
        animator.startAnimation(afterDelay: delay)
        return animator
    }
}
