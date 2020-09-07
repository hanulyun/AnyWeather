//
//  CustomView.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class CustomView: UIView {
    class func instantiate() -> Self {
        return loadFromNib(self)
    }
    
    class func loadFromNib<T>(_ type: T.Type) -> T {
        let className: String = String(describing: self)
        return UINib(nibName: className, bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! T
    }
}
