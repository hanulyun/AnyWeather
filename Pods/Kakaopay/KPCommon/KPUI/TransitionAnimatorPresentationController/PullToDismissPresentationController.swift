//
//  PullToDismissPresentationController.swift
//  Kakaopay
//
//  Created by henry.my on 2020/01/09.
//

import UIKit

open class PullToDismissPresentationController: UIPresentationController, TransitionHandleable {
    public convenience init(presentedViewController presented: UIViewController, presenting: UIViewController?,
                     gestureDismissFraction: CGFloat = 0.3, gestureViewProvider: (() -> UIView)?) {
        self.init(presentedViewController: presented, presenting: presenting)
        self.gestureViewProvider = gestureViewProvider
        self.gestureDismissFraction = gestureDismissFraction
    }
    
    private var gestureViewProvider: (() -> UIView)?
    private var gestureDismissFraction: CGFloat = 0.3

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(actionPan(_ :)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        return gesture
    }()
    private var panGestureIsRunning = false

    override open func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        guard completed else { return }
        
        // presentation 이 완료되면, dimiss 를 위해 pan gesture 를 등록.
        let gestureView = self.gestureViewProvider?() ?? containerView
        gestureView?.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func actionPan(_ recognizer: UIPanGestureRecognizer) {
        guard let gestureView = self.gestureViewProvider?() ?? containerView else { return }
        let verticalMove = recognizer.translation(in: gestureView).y
        let percent = verticalMove / gestureView.bounds.height
        
        switch recognizer.state {
            case .began:
                if verticalMove <= 0 { return }
                panGestureIsRunning = true
                recognizer.setTranslation(.zero, in: gestureView)
                transitioningHandler.isInteractive = true
                presentedViewController.dismiss(animated: true)

            case .changed:
                if !panGestureIsRunning { return }
                transitioningHandler.updateAnimator(percent)

            case .ended, .cancelled:
                if !panGestureIsRunning { return }
                if percent < gestureDismissFraction {
                    gestureView.isUserInteractionEnabled = false
                    transitioningHandler.cancelAnimator() { _ in
                        gestureView.isUserInteractionEnabled = true
                    }
                } else {
                    gestureView.isUserInteractionEnabled = false
                    transitioningHandler.finishAnimator() { _ in
                        gestureView.isUserInteractionEnabled = true
                    }
                }
                panGestureIsRunning = false

            default:
                break
        }
    }
}
