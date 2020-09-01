//
//  UIApplication+Extensions.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/08.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension UIApplication {
    class func firstKeyWindow() -> UIViewController? {
        if let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            return keyWindow.rootViewController
        }
        return nil
    }
}
