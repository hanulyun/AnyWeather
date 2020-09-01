//
//  InternalTextFieldNotification.swift
//  AloeStackView
//
//  Created by henry on 11/03/2019.
//

import UIKit

class InternalTextFieldNotification {
    weak var _textField: UITextField!
    
    init(_ textField: UITextField) {
        self._textField = textField
    }
    
    // closure-based textField event subscribe.
    var textValidate: ((String?) -> String?)? {
        didSet {
            textValidateNotification = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: _textField, queue: OperationQueue.main) { [weak self] (notification) in
                if let textValidate = self?.textValidate {
                    let validatedText: String? = textValidate(self?._textField?.text)
                    if self?._textField.text != validatedText {
                        self?._textField.text = validatedText
                    }
                }
            }
        }
    }
    
    var textDidChange: ((String?) -> Void)? {
        didSet {
            textDidChangeNotification = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: _textField, queue: OperationQueue.main) { [weak self] (notification) in
                if let textDidChange = self?.textDidChange {
                    textDidChange(self?._textField?.text)
                }
            }
        }
    }
    
    var textDidBeginEditing: ((String?) -> Void)? {
        didSet {
            textDidBeginEditingNotification = NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: _textField, queue: OperationQueue.main) { [weak self] (notification) in
                if let textDidBeginEditing = self?.textDidBeginEditing {
                    textDidBeginEditing(self?._textField?.text)
                }
            }
        }
    }
    
    var textDidEndEditing: ((String?) -> Void)? {
        didSet {
            textDidEndEditingNotification = NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: _textField, queue: OperationQueue.main) { [weak self] (notification) in
                if let textDidEndEditing = self?.textDidEndEditing {
                    textDidEndEditing(self?._textField?.text)
                }
            }
        }
    }
    
    private var textValidateNotification: NSObjectProtocol? {
        willSet { if let textValidateNotification = self.textValidateNotification { NotificationCenter.default.removeObserver(textValidateNotification) } }
    }
    
    private var textDidChangeNotification: NSObjectProtocol? {
        willSet { if let textDidChangeNotification = self.textDidChangeNotification { NotificationCenter.default.removeObserver(textDidChangeNotification) } }
    }
    
    private var textDidBeginEditingNotification: NSObjectProtocol? {
        willSet { if let textDidBeginEditingNotification = self.textDidBeginEditingNotification { NotificationCenter.default.removeObserver(textDidBeginEditingNotification) } }
    }
    
    private var textDidEndEditingNotification: NSObjectProtocol? {
        willSet { if let textDidEndEditingNotification = self.textDidEndEditingNotification { NotificationCenter.default.removeObserver(textDidEndEditingNotification) } }
    }
    
    deinit {
        textDidChangeNotification = nil
        textValidateNotification = nil
        textDidEndEditingNotification = nil
        textDidBeginEditingNotification = nil
    }
}
