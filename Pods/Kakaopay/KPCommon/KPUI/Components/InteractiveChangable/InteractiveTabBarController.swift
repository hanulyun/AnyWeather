//
//  InteractiveTabBarController.swift
//  KPCommon
//
//  Created by kali_company on 22/02/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import UIKit

public protocol InteractiveTabBarControllerOwner: class {
    func didChangeSelectedIndex(index: Int, by: InteractiveTabBarController.ActionSource)
}

open class InteractiveTabBarController: UITabBarController {
    public enum ActionSource {
        case gesture
        case external
    }
    
    open override var selectedIndex: Int {
        didSet {
            if oldValue != selectedIndex {
                if let owner = owner {
                    self.tabBarView?.tabBarControllerDidSelectedIndex(selectedIndex)
                    owner.didChangeSelectedIndex(index: selectedIndex, by: .external)
                }
            }
        }
    }
    
    private var transitionGesture: TransitionHorizontalGesture?
    private(set) var isSelecting = false
    private var isCanceled = false
    
    weak public var tabBarView: InteractiveTabMenuView?
    public var useDefaultTransition = false
    
    weak public var owner: InteractiveTabBarControllerOwner?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        self.transitioningDelegate = self.transitioningHandler
        prepareTransitionGesture()
    }
    
    private func prepareTransitionGesture() {
        transitionGesture = TransitionHorizontalGesture(transitioningHandler:self.transitioningHandler,
                                                        didStartGesture: { [weak self] handler in
                                                            self?.handleStartingGesture(gestureHandler: handler)
            },
                                                        didFinishGesture: { [weak self] handler in
                                                            guard let self = self else { return }
                                                            
                                                            self.handleFinishingGesture(gestureHandler: handler)
                                                            if !handler.isCanceled {
                                                                self.tabBarView?.tabBarControllerDidSelectedIndex(self.selectedIndex)
                                                                self.owner?.didChangeSelectedIndex(index: self.selectedIndex, by: .gesture)
                                                            }
            },
                                                        shouldStartGesture: { [weak self] (handler) -> Bool in
                                                            return self?.handleShouldStartGesture(gestureHandler: handler) ?? false
        })
        view.addGestureRecognizer(transitionGesture!)
    }
    
    private func handleStartingGesture(gestureHandler: TransitionGestureHandler) {
        guard let handler = gestureHandler as? TransitionHorizontalGestureHandler, !isSelecting else {
            return
        }
        let nextSelectedIndex = selectedIndex + (handler.isLeftDirection ? 1 : -1)
        isSelecting = true
        selectedViewController = self.viewControllers?[nextSelectedIndex]
    }
    
    private func handleFinishingGesture(gestureHandler: TransitionGestureHandler) {
        isSelecting = false
    }
    
    private func handleShouldStartGesture(gestureHandler: TransitionGestureHandler) -> Bool {
        guard self.transitioningHandler.isEnabled else {
            return false
        }
        
        guard let handler = gestureHandler as? TransitionHorizontalGestureHandler else {
            return false
        }
        
        if handler.isLeftDirection && selectedIndex == ((viewControllers?.count ?? 0) - 1) {
            return false
        }
        if !handler.isLeftDirection && selectedIndex == 0 {
            return false
        }
        
        return true
    }
}

extension InteractiveTabBarController: TransitionAnimatable, UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return (isCanceled || useDefaultTransition) ? nil : transitioningHandler
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (transitioningHandler.isInteractiveInternal && !useDefaultTransition) ? transitioningHandler : nil
    }
    
    public func presentTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        let to = context.viewController(forKey: .to)
        let from = context.viewController(forKey: .from)
        
        if let to = to, let from = from,
            let toIndex = self.viewControllers?.firstIndex(of: to),
            let fromIndex = self.viewControllers?.firstIndex(of: from) {
            return SlidePropertyAnimator(context: context, state: .present, direction: toIndex >= fromIndex ? .left : .right, duration: 0.3)
        }
        return SlidePropertyAnimator(context: context, state: .present, direction: .left, duration: 0.3)
    }
    
    public func dismissTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator()
    }
}
