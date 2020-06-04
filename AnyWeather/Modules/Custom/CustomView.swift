//
//  CustomView.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class CustomView: UIView {
    
    func setInit(_ backColor: UIColor = .clear) {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = backColor
        clipsToBounds = true
        
        configureAutolayouts()
    }
    
    func configureAutolayouts() { }
}
