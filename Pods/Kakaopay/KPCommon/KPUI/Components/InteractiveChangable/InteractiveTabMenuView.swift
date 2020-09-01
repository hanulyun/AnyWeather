//
//  InteractiveTabMenuView.swift
//  KPCommon
//
//  Created by kali_company on 22/02/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import UIKit

open class InteractiveTabMenuView: TabBarView {
    
    @IBOutlet private var bottomLineLeadings: [NSLayoutConstraint]!
    @IBOutlet private var bottomLineWidths: [NSLayoutConstraint]!
    @IBOutlet private var height: NSLayoutConstraint? {
        didSet {
            originalHeight = height?.constant ?? 0.0
        }
    }
    private var originalHeight: CGFloat = 0.0
    
    @IBOutlet override weak public var tabBarController: UITabBarController! {
        didSet {
            // replace default tabBar(UITabBar) to custom tabBar(UIView)
            (tabBarController as? InteractiveTabBarController)?.tabBarView = self
        }
    }
    
    @objc override func actionSelect(_ button: UIButton) {
        if ((tabBarController as? InteractiveTabBarController)?.isSelecting ?? false) { return }
        
        if let selectedIndex = buttons.firstIndex(of: button) {
            tabBarController.selectedIndex = selectedIndex
        }
    }
    
    override open func tabBarControllerDidSelectedIndex(_ index: Int) {
        super.tabBarControllerDidSelectedIndex(index)
        
        for index in 0..<bottomLineLeadings.count {
            if index == tabBarController.selectedIndex {
                bottomLineLeadings[index].priority = .defaultHigh
                bottomLineWidths[index].priority = .defaultHigh
            }
            else {
                bottomLineLeadings[index].priority = .defaultLow
                bottomLineWidths[index].priority = .defaultLow
            }
        }
        
        UIView.animate(withDuration: 0.2 , delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
        })
    }
    
    override open var isHidden: Bool {
        didSet {
            height?.constant = isHidden ? 0.0 : originalHeight
        }
    }

}
