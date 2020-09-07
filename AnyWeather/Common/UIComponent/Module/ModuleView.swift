//
//  ModuleView.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class ModuleView: UIView {
    class func instantiate() -> Self {
        return loadFromNib(self)
    }
    
    class func loadFromNib<T>(_ type: T.Type) -> T {
        let className: String = String(describing: self)
        return UINib(nibName: className, bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! T
    }
}
