//
//  TransitionHorizontalGesture.swift
//  KPCommon
//
//  Created by kali_company on 19/02/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import UIKit

public class TransitionHorizontalGesture: UIPanGestureRecognizer {
    public let gestureHandler: TransitionHorizontalGestureHandler
    
    public init(transitioningHandler: TransitioningHandler,
                didStartGesture: ((TransitionGestureHandler) -> ())? = nil,
                didFinishGesture: ((TransitionGestureHandler) -> ())? = nil,
                shouldStartGesture: ((TransitionGestureHandler) -> Bool)? = nil) {
        let gestureHandler = TransitionHorizontalGestureHandler(transitioningHandler: transitioningHandler,
                                                                didStartGesture: didStartGesture,
                                                                didFinishGesture: didFinishGesture,
                                                                shouldStartGesture: shouldStartGesture)
        self.gestureHandler = gestureHandler
        super.init(target: gestureHandler, action: #selector(gestureHandler.handleSwipe(_:)))
        self.delegate = gestureHandler
    }
}

public class TransitionHorizontalGestureHandler: NSObject, TransitionGestureHandler, UIGestureRecognizerDelegate {
    public var transitioningHandler: TransitioningHandler?
    public var didStartGesture: ((TransitionGestureHandler) -> ())?
    public var didFinishGesture: ((TransitionGestureHandler) -> ())?
    public var shouldStartGesture: ((TransitionGestureHandler) -> Bool)?
    
    public var isLeftDirection = false
    public var isInteractive = false
    public var isCanceled = false
    
    init(transitioningHandler: TransitioningHandler,
         didStartGesture: ((TransitionGestureHandler) -> ())? = nil,
         didFinishGesture: ((TransitionGestureHandler) -> ())? = nil,
         shouldStartGesture: ((TransitionGestureHandler) -> Bool)? = nil) {
        super.init()
        
        self.transitioningHandler = transitioningHandler
        self.didStartGesture = didStartGesture
        self.didFinishGesture = didFinishGesture
        self.shouldStartGesture = shouldStartGesture
    }
    
    @objc func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        let translate = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)
        var ratio = translate.x / (gesture.view?.bounds.width ?? translate.x)
        
        if isLeftDirection { ratio = ratio * -1 }
        
        switch gesture.state {
        case .began:
            isCanceled = false
            isInteractive = true
            transitioningHandler?.isInteractiveInternal = true
            didStartGesture?(self)
        case .changed:
            transitioningHandler?.update(ratio)
        case .cancelled:
            isCanceled = true
            transitioningHandler?.cancel()
            finalizeGesture(false)
        case .failed:
            transitioningHandler?.cancel()
            finalizeGesture(false)
        case .ended:
            if (isLeftDirection && velocity.x < 0) || (!isLeftDirection && velocity.x > 0) || (velocity.x == 0 && ratio > 0.5) {
                transitioningHandler?.finish()
            }
            else {
                isCanceled = true
                transitioningHandler?.cancel()
            }
            
            finalizeGesture(true)
        default:
            break
        }
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
        
        if velocity.x.magnitude < velocity.y.magnitude { return false }
        
        isLeftDirection = velocity.x < 0
        if !(shouldStartGesture?(self) ?? false) { return false }
        
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    private func finalizeGesture(_ isComplete: Bool) {
        isInteractive = false
        transitioningHandler?.isInteractiveInternal = false
        if isComplete { self.didFinishGesture?(self) }
        self.isCanceled = false
    }
}
