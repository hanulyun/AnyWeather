//
//  OverlayContainerViewController.swift
//  KPUI
//
//  Created by henry on 2018. 2. 22..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public class OverlayContainerViewController: UIViewController, ContainerViewController {
    
    public func containerView(for identifier: String?) -> UIView {
        return self.view
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let presentedViewController = self.presentedViewController else {
            return .default
        }
        return presentedViewController.preferredStatusBarStyle
    }
    
    public override func loadView() {
        view = TouchDisableView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.clear
    }
}
