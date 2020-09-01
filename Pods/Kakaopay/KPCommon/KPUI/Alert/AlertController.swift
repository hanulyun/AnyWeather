//
//  AlertController.swift
//  KPUI
//
//  Created by henry on 2018. 1. 22..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public class AlertController: UIAlertController {
    
    private var actionHandler: ((_ buttonIndex: Int) -> Void)?
    internal class var alertStyle: UIAlertController.Style {
        return .alert
    }

    private func initialize(buttons: [String], cancelButtonIndex: Int? = nil, destructiveButtonIndex: Int? = nil) {
        for index in 0..<buttons.count {
            let button = buttons[index]
            var style: UIAlertAction.Style
            if cancelButtonIndex != nil && index == cancelButtonIndex {
                style = .cancel
            } else if destructiveButtonIndex != nil && index == destructiveButtonIndex {
                style = .destructive
            } else {
                style = .default
            }
            let action = UIAlertAction(title: button, style: style, handler: { [weak self] _ in
                guard let weakSelf = self else {
                    return
                }
                if let actionHandler = weakSelf.actionHandler {
                    actionHandler(index)
                }
            })
            addAction(action)
        }
    }
}

extension AlertController: AlertPresentable {

    public static func instantiate(title: String?, message: String?,
                                   buttons: [String], cancelButtonIndex: Int? = nil, destructiveButtonIndex: Int? = nil,
                                   actionHandler: ((_ buttonIndex: Int) -> Void)? = nil) -> AlertPresentableViewController? {
        let alertController = self.init(title: title, message: message, preferredStyle: alertStyle)
        alertController.actionHandler = actionHandler
        alertController.initialize(buttons: buttons, cancelButtonIndex: cancelButtonIndex, destructiveButtonIndex: destructiveButtonIndex)
        return alertController;
    }
}
