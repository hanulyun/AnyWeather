//
//  PayBottomView.swift
//  PayApp
//
//  Created by henry on 14/02/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import UIKit

/*
 IBOutlet 으로 커스텀 buttons 을 순서대로 연결하고,
 코드에서 사용할 tabBarController 를 연결하면 됩니다.
 */
open class TabBarView: UIView {
    //private var tabBarControllerSelectedIndexKeyValueObservation: NSKeyValueObservation?
    
    public var isEnabled: Bool = true {
        didSet {
            for button in buttons {
                button.isEnabled = isEnabled
            }
        }
    }
    
    @IBOutlet public var buttons: [UIButton]! {
        didSet {
            for button in buttons {
                button.addTarget(self, action: #selector(actionSelect(_:)), for: .touchUpInside)
            }
        }
    }
    
    @objc func actionSelect(_ button: UIButton) {
        if let selectedIndex = buttons.firstIndex(of: button) {
            tabBarController.selectedIndex = selectedIndex
        }
    }
    
    @IBOutlet weak public var tabBarController: UITabBarController! {
        didSet {
            // replace default tabBar(UITabBar) to custom tabBar(UIView)
            tabBarController.tabBar.isHidden = true
            tabBarControllerDidSet()
        }
    }
    
    // 추가적인 initialize 과정이 있을 경우 아래 함수를 override 할 수 있습니다.
    open func tabBarControllerDidSet() {}
    
    // selected index 변경이 있을 경우 아래 함수를 override 하여 구현 할 수 있습니다.
    open func tabBarControllerDidSelectedIndex(_ index: Int) {
        for index in 0...index {
            for button in buttons {
                button.isSelected = false
            }
            buttons[index].isSelected = true
        }
    }
}
