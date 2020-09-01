//
//  UITextField+Notification.swift
//  AloeStackView
//
//  Created by henry on 11/03/2019.
//

import UIKit

private var PayTextFieldNotificationAssociatedObjectKey: Void?
extension Pay where Base: UITextField {
    private var _notification: InternalTextFieldNotification {
        get {
            let textField = self.base as UITextField
            guard let notification: InternalTextFieldNotification = objc_getAssociatedObject(textField, &PayTextFieldNotificationAssociatedObjectKey) as? InternalTextFieldNotification else {
                let newNotification = InternalTextFieldNotification(textField)
                objc_setAssociatedObject(textField, &PayTextFieldNotificationAssociatedObjectKey, newNotification, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return newNotification
            }
            return notification
        }
    }
    
    public var textValidate: ((String?) -> String?)? {
        get { return _notification.textValidate }
        set { _notification.textValidate = newValue }
    }
    
    public var textDidChange: ((String?) -> Void)? {
        get { return _notification.textDidChange }
        set { _notification.textDidChange = newValue }
    }
    
    public var textDidBeginEditing: ((String?) -> Void)? {
        get { return _notification.textDidBeginEditing }
        set { _notification.textDidBeginEditing = newValue }
    }
    
    public var textDidEndEditing: ((String?) -> Void)? {
        get { return _notification.textDidEndEditing }
        set { _notification.textDidEndEditing = newValue }
    }
}
