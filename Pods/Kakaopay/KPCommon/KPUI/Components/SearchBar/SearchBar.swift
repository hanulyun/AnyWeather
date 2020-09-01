//
//  SearchBar.swift
//  KPUI
//
//  Created by Miller on 2018. 5. 3..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public protocol SearchBarDelegate : NSObjectProtocol {
    func searchBarShouldBeginEditing(_ searchBar: SearchBar) -> Bool
    func searchBarTextDidBeginEditing(_ searchBar: SearchBar)
    func searchBarShouldEndEditing(_ searchBar: SearchBar) -> Bool
    func searchBarTextDidEndEditing(_ searchBar: SearchBar)
    
    func searchBarTextDidClear(_ searchBar: SearchBar)
    
    func searchBar(_ searchBar: SearchBar, textDidChange searchText: String)
    func searchBar(_ searchBar: SearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    
    func searchBarSearchButtonClicked(_ searchBar: SearchBar)

    
    func searchBarWillActive(_ searchBar: SearchBar)
    func searchBarDidActive(_ searchBar: SearchBar)
    func searchBarWillDeactive(_ searchBar: SearchBar)
    func searchBarDidDeactive(_ searchBar: SearchBar)
}

public extension SearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: SearchBar) -> Bool { return true }
    func searchBarTextDidBeginEditing(_ searchBar: SearchBar) { }
    func searchBarShouldEndEditing(_ searchBar: SearchBar) -> Bool { return true }
    func searchBarTextDidEndEditing(_ searchBar: SearchBar) { }

    func searchBarTextDidClear(_ searchBar: SearchBar) {}
    
    func searchBar(_ searchBar: SearchBar, textDidChange searchText: String) { }
    func searchBar(_ searchBar: SearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool  { return true }

    func searchBarSearchButtonClicked(_ searchBar: SearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarWillActive(_ searchBar: SearchBar) { }
    func searchBarDidActive(_ searchBar: SearchBar) { }
    func searchBarWillDeactive(_ searchBar: SearchBar) { }
    func searchBarDidDeactive(_ searchBar: SearchBar) { }
}




open class SearchBar: UIView {
    private var internalSearchBarProxyDelegate: InternalSearchBarProxyDelegate?
    public var delegate: SearchBarDelegate? {
        get { return internalSearchBarProxyDelegate?.delegate }
        set {
            guard let delegate = newValue else {
                internalSearchBarProxyDelegate = nil
                return
            }

            
            if internalSearchBarProxyDelegate == nil {
                internalSearchBarProxyDelegate = InternalSearchBarProxyDelegate(searchBar: self, delegate: delegate)
                searchTextField.delegate = internalSearchBarProxyDelegate
            } else {
                internalSearchBarProxyDelegate?.delegate = delegate
            }
        }
    }
    @IBOutlet public var ibDelegate: AnyObject? {
        get { return delegate }
        set { delegate = newValue as? SearchBarDelegate }
    }
    
    
    @IBOutlet private weak var stackView: UIStackView!
    
    @IBOutlet private weak var searchTextFieldLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBInspectable var placeholder: String? {
        get { return searchTextField.placeholder }
        set { searchTextField.placeholder = newValue }
    }
    @IBInspectable var text: String? {
        get { return searchTextField.text }
        set { searchTextField.text = newValue }
    }
    
    @IBOutlet private weak var promptLabel: UILabel!
    @IBInspectable var prompt: String? {
        get { return promptLabel.text }
        set { promptLabel.text = newValue}
    }
    
    @IBOutlet var searchIconImageViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var searchIconImageView: UIImageView!
    @IBInspectable var searchIconImage: UIImage? {
        get { return searchIconImageView.image }
        set {
            searchIconImageView.image = newValue

            if searchIconImage != nil {
                searchTextFieldLeftConstraint.constant = 30.0 + newValue!.size.width + 12.0
                searchIconImageView.isHidden = false
            } else {
                searchIconImageView.isHidden = true
            }
        }
    }
    
    @IBInspectable var clearIconImage: UIImage? {
        get {
            guard let imageView = searchTextField.rightView as? UIImageView else {
                return nil
            }
            return imageView.image
        }
        set {
            if let clearImage = newValue {
                let clearButton = UIButton(type: .custom)
                clearButton.frame = CGRect(x: 0.0, y: 0.0, width: clearImage.size.width, height: clearImage.size.height)
                clearButton.setImage(clearImage, for: .normal)
                clearButton.addTarget(self, action: #selector(actionClear(_:)), for: .touchUpInside)
                searchTextField.rightView = clearButton
                searchTextField.rightViewMode = .whileEditing
            } else {
                searchTextField.rightView = nil
                searchTextField.rightViewMode = .never
            }
        }
    }
    
    fileprivate var activeAnimator: UIViewPropertyAnimator
    fileprivate var deactiveAnimator: UIViewPropertyAnimator
    
    
    
    public required init?(coder aDecoder: NSCoder) {
        activeAnimator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.85, animations: nil)
        deactiveAnimator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.85, animations: nil)
        
        super.init(coder: aDecoder)
        
        let nib = UINib(nibName: "SearchBar", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: searchTextField, queue: OperationQueue.main) { [weak self] (notification) in
            guard let textField = self?.searchTextField else {
                return
            }
            
            var text = ""
            if let mustText = textField.text {
                text = mustText
            }
            
            self?.internalSearchBarProxyDelegate?.textField(textField, didChangeText: text)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: self)
    }

    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        return searchTextField.resignFirstResponder()
    }
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        return searchTextField.becomeFirstResponder()
    }
}


extension SearchBar {
    public func clear() {
        privateClear()
    }
    
    public func active(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        self.layoutIfNeeded()
        
        if deactiveAnimator.isRunning {
            deactiveAnimator.stopAnimation(false)
            deactiveAnimator.finishAnimation(at: .current)
        }

        
        searchIconImageViewLeftConstraint.isActive = true
        delegate?.searchBarWillActive(self)
        activeAnimator.addAnimations {
            self.layoutIfNeeded()
            self.promptLabel.alpha = 0.0
            self.searchTextField.alpha = 1.0
        }
        activeAnimator.addCompletion { (pos) in
            if pos == .end {
                self.delegate?.searchBarDidActive(self)
                if let completion = completion { completion() }
            }
        }
        activeAnimator.startAnimation()
    }
    
    public func deactive(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        if activeAnimator.isRunning {
            activeAnimator.stopAnimation(false)
            activeAnimator.finishAnimation(at: .current)
        }
        
        delegate?.searchBarWillDeactive(self)
        if let text = searchTextField.text, text.count > 0 {
        } else {
            searchIconImageViewLeftConstraint.isActive = false
            deactiveAnimator.addAnimations {
                self.layoutIfNeeded()
                self.promptLabel.alpha = 1.0
                self.searchTextField.alpha = 0.0
            }
            deactiveAnimator.addCompletion { (pos) in
                if pos == .end {
                    self.delegate?.searchBarDidDeactive(self)
                    if let completion = completion { completion() }
                }
            }
            deactiveAnimator.startAnimation()
        }
    }
}


private extension SearchBar {
    @IBAction private func actionActive(_ sender: UITapGestureRecognizer) {
        active { self.becomeFirstResponder() }
    }

    @objc private func actionClear(_ sender: UIButton) {
        privateClear()
    }
    

    private func privateClear() {
        searchTextField.text = ""
        internalSearchBarProxyDelegate?.textFieldDidClear()
        
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: searchTextField)
    }
}



private class InternalSearchBarProxyDelegate: NSObject, UITextFieldDelegate {
    weak var searchBar: SearchBar!
    weak var delegate: SearchBarDelegate?
    
    init(searchBar: SearchBar, delegate: SearchBarDelegate?) {
        self.searchBar = searchBar
        self.delegate = delegate
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.searchBarShouldBeginEditing(searchBar) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.searchBarTextDidBeginEditing(searchBar)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.searchBarShouldEndEditing(searchBar) ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.searchBarTextDidEndEditing(searchBar)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        delegate?.searchBarTextDidEndEditing(searchBar)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.searchBarSearchButtonClicked(searchBar)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.searchBar(searchBar, shouldChangeTextIn: range, replacementText: string) ?? true
    }
    
    func textField(_ textField: UITextField, didChangeText: String) {
        delegate?.searchBar(searchBar, textDidChange: didChangeText)
    }
    
    func textFieldDidClear() {
        delegate?.searchBarTextDidClear(searchBar)
    }
}
