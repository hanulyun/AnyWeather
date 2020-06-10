//
//  BaseViewController.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, ViewProtocol {
    
    var guide: UILayoutGuide {
        return view.safeAreaLayoutGuide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        configureAutolayouts()
        bindData()
    }

    func configureAutolayouts() { }
    func bindData() { }
    
    func getStatusHeight() -> CGFloat {
        if #available(iOS 13.0, *) {
            let window: UIWindow? = UIApplication.shared.windows.filter({$0.isKeyWindow}).first
            return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
        return UIApplication.shared.statusBarFrame.height
    }
}
