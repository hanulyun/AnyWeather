//
//  KeyboardObserver.swift
//  Kakaopay
//
//  Created by kali_company on 2018. 5. 14..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

public class KeyboardObserver {
    private weak var owner: KeyboardObservable?
    
    public init(owner: KeyboardObservable) {
        self.owner = owner
    }
    
    public func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleKeyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleKeyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleKeyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    public func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension KeyboardObserver {
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if notification.name == UIResponder.keyboardWillChangeFrameNotification {
            owner?.keyboardWillChangeFrame(notification: notification)
        } else if notification.name == UIResponder.keyboardWillShowNotification {
            owner?.payKeyboardWillShow(notification: notification)
        } else if notification.name == UIResponder.keyboardWillHideNotification {
            owner?.payKeyboardWillHide(notification: notification)
        }
    }
}
