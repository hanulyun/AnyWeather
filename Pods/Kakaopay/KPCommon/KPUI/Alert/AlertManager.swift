//
//  AlertManager.swift
//  KPUI
//
//  Created by henry on 2018. 1. 22..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public typealias AlertPresentableViewController = UIViewController & AlertPresentable
public protocol AlertPresentable {
    static func instantiate(title: String?, message: String?,
                            buttons: [String], cancelButtonIndex: Int?, destructiveButtonIndex: Int?,
                            actionHandler: ((_ buttonIndex: Int) -> Void)?) -> AlertPresentableViewController?
}

public class AlertManager {
    public static let shared: AlertManager = AlertManager()
    
    public weak private(set) var presentedAlertController: AlertPresentableViewController?
    
    @discardableResult
    public func present(on: UIViewController, type: (AlertPresentable).Type = AlertController.self,
                        title: String?, message: String?,
                        buttons: [String], cancelButtonIndex: Int? = nil, destructiveButtonIndex: Int? = nil,
                        actionHandler: ((_ buttonIndex: Int) -> Void)? = nil) -> AlertPresentableViewController? {
        
        guard let alertController = type.instantiate(title: title, message: message, buttons: buttons, cancelButtonIndex: cancelButtonIndex, destructiveButtonIndex: destructiveButtonIndex, actionHandler: actionHandler) else {
            return nil
        }
        
        present(on: on, alert: alertController)
        return alertController
    }
    
    public func present(on: UIViewController, alert: AlertPresentableViewController) {
        /*
         if on is being dismissed or is moving from parent VC, choice parent instead.
         alert 을 띄우려는 대상 viewController 가 곧 사라지는 상태라면 present 해도 의미가 없기 때문에,
         명시적으로 presenting 을 찾아서 present 가 되도록 변경해 줍니다.
        */
        var presenting = on
        if (presenting.isBeingDismissed || presenting.isMovingFromParent), presenting.presentingViewController != nil {
            presenting = presenting.presentingViewController!
        } else if let navigation = presenting.navigationController,
            (navigation.isBeingDismissed || navigation.isMovingFromParent), navigation.presentingViewController != nil {
            presenting = navigation.presentingViewController!
        }
        
        presenting.present(alert, animated: true, completion: nil)
        presentedAlertController = alert
    }
    
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        presentedAlertController?.dismiss(animated: animated, completion: completion)
    }
}
