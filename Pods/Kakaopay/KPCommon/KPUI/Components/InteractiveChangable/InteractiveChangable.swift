//
//  ChangableViewController.swift
//  KPCommon
//
//  Created by kali_company on 22/02/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import Foundation

public protocol InteractiveChangable {
    var tabBarView: InteractiveTabMenuView? { get set }
    var tabBarViewController: InteractiveTabBarController! { get set }
}
