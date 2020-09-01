//
//  UIViewController+KeyboardObservable.swift
//  Kakaopay
//
//  Created by kali_company on 2018. 5. 14..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

private var KeyboardObservableBottomSpaceAssociatedObjectKey: Void?
private var KeyboardObservableScrollViewAssociatedObjectKey: Void?
private var KeyboardObservableOriginalBottomSpaceAssociatedObjectKey: Void?
private var KeyboardObservableOriginalInsetsAssociatedObjectKey: Void?
private var KeyboardObserverAssociatedObjectKey: Void?
extension UIViewController: KeyboardObservable {
    @IBOutlet public var bottomSpace: NSLayoutConstraint? {
        set {
            objc_setAssociatedObject(self, &KeyboardObservableBottomSpaceAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(self, &KeyboardObservableOriginalBottomSpaceAssociatedObjectKey, newValue?.constant, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &KeyboardObservableBottomSpaceAssociatedObjectKey) as? NSLayoutConstraint
        }
    }
    
    @IBOutlet public var contentInsetable: UIScrollView? {
        set {
            objc_setAssociatedObject(self, &KeyboardObservableScrollViewAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(self, &KeyboardObservableOriginalInsetsAssociatedObjectKey, newValue?.contentInset, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &KeyboardObservableScrollViewAssociatedObjectKey) as? UIScrollView
        }
    }
    
    public var originalBottomSpace: CGFloat {
        get {
            return objc_getAssociatedObject(self, &KeyboardObservableOriginalBottomSpaceAssociatedObjectKey) as! CGFloat
        }
    }
    
    public var originalInsets: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &KeyboardObservableOriginalInsetsAssociatedObjectKey) as! UIEdgeInsets
        }
    }
    
    public var keyboardObserver: KeyboardObserver {
        get {
            var observer = objc_getAssociatedObject(self, &KeyboardObserverAssociatedObjectKey) as? KeyboardObserver
            if (observer == nil) {
                observer = KeyboardObserver(owner: self)
                objc_setAssociatedObject(self, &KeyboardObserverAssociatedObjectKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return observer!
        }
    }
    
    @objc public func keyboardWillChangeFrame(notification: NSNotification) {
        handleChangingKeyboardFrame(notification: notification)
    }
    
    @objc open func payKeyboardWillShow(notification: NSNotification) {}
    @objc open func payKeyboardWillHide(notification: NSNotification) {}
}
    
extension UIViewController {
    @objc open func handleChangingKeyboardFrame(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if let bottomSpaceConstraint = bottomSpace {
                if endFrameY >= UIScreen.main.bounds.size.height {
                    bottomSpaceConstraint.constant = originalBottomSpace
                    UIView.animate(withDuration: duration,
                                   delay: TimeInterval(0),
                                   options: animationCurve,
                                   animations: { self.view.layoutIfNeeded() },
                                   completion: nil)
                } else {
                    bottomSpaceConstraint.constant = (endFrame?.size.height ?? 0.0) + originalBottomSpace
                    UIView.animate(withDuration: duration,
                                   delay: TimeInterval(0.01),
                                   options: animationCurve,
                                   animations: { self.view.layoutIfNeeded() },
                                   completion: nil)
                }
            }
            if let scrollView = contentInsetable {
                if endFrameY >= UIScreen.main.bounds.size.height {
                    scrollView.contentInset = originalInsets
                } else {
                    scrollView.contentInset = UIEdgeInsets(top: originalInsets.top, left: originalInsets.left, bottom: originalInsets.bottom + (endFrame?.size.height ?? 0.0), right: originalInsets.right)
                }
                
                var scrollIndicatorInsets = scrollView.contentInset
                let bottomSafeAreaInsets = view.safeAreaInsets.bottom
                scrollIndicatorInsets.bottom = scrollIndicatorInsets.bottom - bottomSafeAreaInsets
                scrollView.scrollIndicatorInsets = scrollIndicatorInsets
            }
        }
    }
}
