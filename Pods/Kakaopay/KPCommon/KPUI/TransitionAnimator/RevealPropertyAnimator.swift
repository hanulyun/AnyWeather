//
//  RevealPropertyAnimator.swift
//  PayApp
//
//  Created by henry on 02/07/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import UIKit

/*
 안드로이드 Circular Reveal 스타일의 animation 을 정의하는 animator 입니다.
*/
open class RevealPropertyAnimator: UIViewPropertyAnimator {
    /*
     revealView: reveal animation 대상이 되는 view 를 지정합니다.
     revealCenter: reveal animation 이 시작되는 좌표를 지정합니다. (주의: revealView 내의 상대좌표)
     revealColor: reveal animation 색상을 지정합니다.
     usingRevealViewDirectly: containerView(UITransitionView) 를 사용하지 않고 revealView 에 바로 circleView 를 add 하도록 합니다. revealView 가 다른 animation 등에 영향을 받을 때 해당 view 의 frame 안에서 동작하고자 할때 사용할 수 있습니다.
     */
    public convenience init(context: UIViewControllerContextTransitioning, state: TransitionState? = nil, revealView: UIView, revealCenter: CGPoint? = nil, revealColor: UIColor? = nil, usingRevealViewDirectly: Bool = false,
                            duration: TimeInterval = 0.3, curve: UIView.AnimationCurve? = .easeInOut, dampingRatio: CGFloat? = nil) {
        
        self.init(duration: duration, curve: curve, dampingRatio: dampingRatio)
        onAnimate(context: context, state: state, revealView: revealView, revealCenter: revealCenter, revealColor: revealColor, usingRevealViewDirectly: usingRevealViewDirectly)
    }
    
    open func onAnimate(context: UIViewControllerContextTransitioning, state: TransitionState?, revealView: UIView, revealCenter maybeRevealCenter: CGPoint? = nil, revealColor maybeRevealColor: UIColor? = nil, usingRevealViewDirectly: Bool = false) {
        guard let fromViewController = context.viewController(forKey: .from), let toViewController = context.viewController(forKey: .to) else {
            // makes empty animation to cancel.
            context.viewController(forKey: .from)?.view.alpha = 0.0
            self.addAnimations { context.viewController(forKey: .from)?.view.alpha = 1.0 }
            return
        }
        
        let isPresent = (state == nil || state == .present)
        if isPresent {
            toViewController.view.layoutIfNeeded()
        }
        
        let revealFromTransform = isPresent ? CGAffineTransform(scaleX: 0.001, y: 0.001) : CGAffineTransform(scaleX: 1.0, y: 1.0)
        let revealToTransform = isPresent ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: 0.001, y: 0.001)
        let revealRadius = max(revealView.bounds.height, revealView.bounds.width) * 3.0 // more than 2√2(Approximately 2.8284)
        let revealCenter = maybeRevealCenter ?? revealView.center
        let revealColor = maybeRevealColor ?? revealView.backgroundColor

        let circleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: revealRadius, height: revealRadius))
        circleView.backgroundColor = revealColor
        circleView.layer.cornerRadius = revealRadius / 2
        circleView.transform = revealFromTransform
        circleView.center = revealCenter

        let snapshotView = UIView()
        if usingRevealViewDirectly == true {
            revealView.addSubview(circleView)
        } else {
            snapshotView.backgroundColor = .clear
            snapshotView.layer.cornerRadius = revealView.layer.cornerRadius
            snapshotView.layer.maskedCorners = revealView.layer.maskedCorners
            snapshotView.clipsToBounds = true
            context.containerView.addSubview(snapshotView)
            snapshotView.frame = revealView.frame
            snapshotView.addSubview(circleView)
        }
        
        addAnimations {
            circleView.transform = revealToTransform
        }
        addCompletion { _ in
            circleView.removeFromSuperview()
            snapshotView.removeFromSuperview()
        }
        
        if isPresent {
            toViewController.view.isHidden = true
            addCompletion { _ in
                toViewController.view.isHidden = false
            }
        } else {
            fromViewController.view.isHidden = true
        }
    }
}
