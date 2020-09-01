//
//  KeyboardObservable.swift
//  Kakaopay
//
//  Created by kali_company on 2018. 5. 14..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

public protocol KeyboardObservable: class {
    var keyboardObserver: KeyboardObserver { get }
    var bottomSpace: NSLayoutConstraint? { get set }
    
    func keyboardWillChangeFrame(notification: NSNotification)
    func payKeyboardWillShow(notification: NSNotification)
    func payKeyboardWillHide(notification: NSNotification)
}
