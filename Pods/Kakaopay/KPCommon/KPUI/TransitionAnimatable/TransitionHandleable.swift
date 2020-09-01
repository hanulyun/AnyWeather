//
//  TransitionHandleable.swift
//  Kakaopay
//
//  Created by henry.my on 2020/01/10.
//

import UIKit

public protocol TransitionHandleable: NSObjectProtocol {
    var transitioningHandler: TransitioningHandler { get }
}

private var transitioningHandlerAssociatedObjectKey: Void?
extension TransitionHandleable where Self: UIViewController {

    public var transitioningHandler: TransitioningHandler {
        guard let handler = objc_getAssociatedObject(self, &transitioningHandlerAssociatedObjectKey) as? TransitioningHandler else {
            let newHandler = TransitioningHandler(on: self)
            objc_setAssociatedObject(self, &transitioningHandlerAssociatedObjectKey, newHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.transitioningDelegate = newHandler
            self.modalPresentationStyle = .custom
            return newHandler
        }
        return handler
    }
}

private var transitioningHandlerForUIPresentationControllerAssociatedObjectKey: Void?
extension TransitionHandleable where Self: UIPresentationController {

    public var transitioningHandler: TransitioningHandler {
        return objc_getAssociatedObject(self, &transitioningHandlerForUIPresentationControllerAssociatedObjectKey) as! TransitioningHandler
    }
    
    public func setTransitioningHandler(_ handler: TransitioningHandler) {
        objc_setAssociatedObject(self, &transitioningHandlerForUIPresentationControllerAssociatedObjectKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
