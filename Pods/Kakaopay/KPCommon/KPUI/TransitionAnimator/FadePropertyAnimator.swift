//
//  FadeContextPropertyAnimator.swift
//  KPUI
//
//  Created by henry on 2018. 2. 27..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

open class FadePropertyAnimator: UIViewPropertyAnimator {

    convenience public init(context: UIViewControllerContextTransitioning,
                            state: TransitionState, duration: TimeInterval = 0.3, curve: UIView.AnimationCurve = .linear) {
        self.init(toView: context.view(forKey: .to), fromView: context.view(forKey: .from), state: state, duration: duration, curve: curve)
    }
    
    convenience public init(toView: UIView?, fromView: UIView?,
                            state: TransitionState, duration: TimeInterval = 0.3, curve: UIView.AnimationCurve = .linear) {
        self.init(duration: duration, curve: curve, animations: nil)
        
        if state == .present {
            toView?.alpha = 0.0
            self.addAnimations {
                toView?.alpha = 1.0
            }
        } else {
            self.addAnimations {
                fromView?.alpha = 0.0
            }
        }
    }
}



