//
//  UIViewController.swift
//  KPUI
//
//  Created by henry on 2018. 2. 13..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

/*
 implements of Container View Controller
 https://developer.apple.com/library/content/featuredarticles/ViewControllerPGforiPhoneOS/ImplementingaContainerViewController.html
 */
public protocol ContainerViewController {
    // optional
    func containerView(for identifier: String?) -> UIView
    
    // protocol implementation
    func add(content: UIViewController, on: UIView?)
    func remove(content: UIViewController)
    func add(content: UIViewController & TransitionAnimatable, on: UIView?, animated: Bool, completed: ((Bool) -> Void)?)
    func remove(content: UIViewController & TransitionAnimatable, animated: Bool, completed: ((Bool) -> Void)?)
}

extension ContainerViewController where Self: UIViewController {
    public func add(content: UIViewController, on: UIView? = nil) {
        self.addChild(content)

        let containerView = on ?? self.containerView(for: nil)
        content.view.frame = containerView.frame
        content.view.frame.origin = CGPoint.zero
        containerView.addSubview(content.view)
        containerView.fillAnchor.constraints(equalTo: content.view.fillAnchor).isActive = true
        content.didMove(toParent: self)
    }
    
    public func remove(content: UIViewController) {
        content.willMove(toParent: nil)
        content.view.removeFromSuperview()
        content.removeFromParent()
    }
    
    public func add(content: UIViewController & TransitionAnimatable, on: UIView? = nil, animated: Bool, completed: ((Bool) -> Void)? = nil) {
        guard animated else {
            add(content: content)
            return
        }
        
        self.addChild(content)
        let containerView = on ?? self.containerView(for: nil)
        
        content.transitioningHandler.transitionState = .present
        let context = ContainerTransitionContext(from: self, to: content, on: containerView) { didComplete in
            content.didMove(toParent: self)

            guard let completed = completed else { return }
            completed(didComplete)
        }
        content.transitioningHandler.start(using: context)
    }
    
    public func remove(content: UIViewController & TransitionAnimatable, animated: Bool, completed: ((Bool) -> Void)? = nil) {
        guard animated else {
            remove(content: content)
            return
        }
        
        content.willMove(toParent: nil)
        content.removeFromParent()
        
        content.transitioningHandler.transitionState = .dismiss
        let context = ContainerTransitionContext(from: content, to: self, on: self.view) { didComplete in
            content.view.removeFromSuperview()
            
            guard let completed = completed else { return }
            completed(didComplete)
        }
        content.transitioningHandler.start(using: context)
    }
}

