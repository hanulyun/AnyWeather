//
//  NavigationBottomViewPropertyAnimator.swift
//  KPUI
//
//  Created by henry on 2018. 2. 21..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

/*
 화면 하단에서 높이가 변화하는 BottomSheet 형식의 View 를 정의합니다.
 (Navigation 전용!)
 */
public protocol NavigationBottomViewAnimatable: NavigationAnimatable {}

public extension NavigationBottomViewAnimatable where Self: UINavigationController {
    var navigationDimmedView: UIView? {
        let dimmedView = UIView()
        dimmedView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        return dimmedView
    }
    
    func shouldStartTransitionAnimation(from fromVC: UIViewController, to toVC: UIViewController, state: TransitionState) -> Bool {
        let isBottomViewAnimatable: (UIViewController) -> Bool = { viewController in
            if viewController is BottomViewAnimatable {
                return true
            }
            
            if let navigationController = viewController as? UINavigationController, let topViewController = navigationController.topViewController {
                return topViewController is BottomViewAnimatable
            } else if let tabBarController = viewController as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
                return selectedViewController is BottomViewAnimatable
            }
            return false
        }
        
        if state == .present {
            return isBottomViewAnimatable(toVC)
        } else {
            return isBottomViewAnimatable(fromVC)
        }
    }
    
    func pushTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        return NavigationBottomViewPropertyAnimator(self, context: context, state: .present, dimmedView: navigationDimmedView)
    }
    
    func popTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        return NavigationBottomViewPropertyAnimator(self, context: context, state: .dismiss, dimmedView: navigationDimmedView)
    }
}

open class NavigationBottomViewPropertyAnimator: UIViewPropertyAnimator {
    private var dimmedView: UIView?
    private weak var navigationController: UINavigationController!
    
    public convenience init(_ navigationController: UINavigationController, context: UIViewControllerContextTransitioning, state: TransitionState? = nil, dimmedView: UIView? = nil,
                            duration: TimeInterval = 0.3, curve: UIView.AnimationCurve? = .easeInOut, dampingRatio: CGFloat? = nil) {
        self.init(duration: duration, curve: curve, dampingRatio: dampingRatio)
        self.dimmedView = dimmedView
        self.navigationController = navigationController
        onAnimate(context: context, state: state)
    }
    
    open func onAnimate(context: UIViewControllerContextTransitioning, state: TransitionState?) {
        guard let fromContainerViewController = context.viewController(forKey: .from), let toContainerViewController = context.viewController(forKey: .to) else {
            return
        }
        
        let maybeFromViewController = pay.findViewControllerInContainerIfPossible(fromContainerViewController) as? (UIViewController & BottomViewAnimatable)
        let maybeToViewController = pay.findViewControllerInContainerIfPossible(toContainerViewController) as? (UIViewController & BottomViewAnimatable)
        
        // [Optional] default height 가 automatic 일 경우 설정
        if let toViewController = maybeToViewController, toViewController.bottomViewDefaultHeight == BottomViewAutomaticDefaultHeight {
           toViewController.bottomViewDefaultHeight = toViewController.bottomViewHeightConstraint.constant
        }
        if let fromViewController = maybeFromViewController, fromViewController.bottomViewDefaultHeight == BottomViewAutomaticDefaultHeight {
           fromViewController.bottomViewDefaultHeight = fromViewController.bottomViewHeightConstraint.constant
        }
        
        if let fromViewController = maybeFromViewController, let toViewController = maybeToViewController {
            toViewController.bottomViewHeightConstraint.constant = fromViewController.bottomViewHeightConstraint.constant
            toViewController.view.layoutIfNeeded()
            fromViewController.view.layoutIfNeeded()
            
            // experimental code. using dimmed back screen. (TODO: common 으로 내릴때 color 값 전달 필요함.)
            if let dimmedView = self.dimmedView {
                if state == nil || state == .present {
                    fromViewController.bottomView.superview?.addSubview(dimmedView)
                    fromViewController.bottomView.superview?.bringSubviewToFront(fromViewController.bottomView)
                    dimmedView.frame = fromViewController.view.bounds
                } else {
                    toViewController.bottomView.superview?.addSubview(dimmedView)
                    toViewController.bottomView.superview?.bringSubviewToFront(toViewController.bottomView)
                    dimmedView.frame = toViewController.view.bounds
                }
            }
            
            navigationController.navigationBar.alpha = 0.0
            addAnimations {
                toViewController.bottomViewHeightConstraint.constant = toViewController.bottomViewDefaultHeight
                fromViewController.bottomViewHeightConstraint.constant = toViewController.bottomViewDefaultHeight
                toViewController.view.layoutIfNeeded()
                fromViewController.view.layoutIfNeeded()
                
                fromViewController.bottomViewAdditionalAnimations(state: state, key: .from)
                toViewController.bottomViewAdditionalAnimations(state: state, key: .to)
                self.navigationController.navigationBar.alpha = 1.0
            }
            addCompletion { (_) in
                self.dimmedView?.removeFromSuperview()
            }
        }
        
        if state == nil || state == .present, let toViewController = maybeToViewController {
            context.containerView.bringSubviewToFront(toViewController.view)
            toContainerViewController.view.transform = CGAffineTransform(translationX: toContainerViewController.view.frame.width, y: 0.0)
            toViewController.bottomView.transform = CGAffineTransform(translationX: -toContainerViewController.view.frame.width, y: 0.0)
            toViewController.bottomView.alpha = 0.0
            dimmedView?.alpha = 0.0
            addAnimations {
                toContainerViewController.view.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
                toViewController.bottomView.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
                toViewController.bottomView.alpha = 1.0
                self.dimmedView?.alpha = 1.0
            }
            
        } else if state == .dismiss, let fromViewController = maybeFromViewController {
            context.containerView.bringSubviewToFront(fromViewController.view)
            dimmedView?.alpha = 1.0
            addAnimations {
                fromContainerViewController.view.transform = CGAffineTransform(translationX: fromContainerViewController.view.frame.width, y: 0.0)
                fromViewController.bottomView.transform = CGAffineTransform(translationX: -fromContainerViewController.view.frame.width, y: 0.0)
                fromViewController.bottomView.alpha = 0.0
                self.dimmedView?.alpha = 0.0
            }
        }
    }
}

