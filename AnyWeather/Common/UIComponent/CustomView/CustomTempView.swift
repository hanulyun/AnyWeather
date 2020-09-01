//
//  CustomView.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class CustomTempView: UIView, ViewProtocol {
    func setInit(_ backColor: UIColor = .clear) {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = backColor
        clipsToBounds = true
        
        configureAutolayouts()
    }
    
    func configureAutolayouts() { }
    func bindData() { }
    
    func getMaxIndexLabel(_ labels: [UILabel]) -> UILabel {
        var labelWidths: [CGFloat] = []
        labels.forEach { labelWidths.append($0.intrinsicContentSize.width) }
        
        let max: CGFloat = labelWidths.max() ?? 0
        let maxIndex: Int = labelWidths.indices.filter { labelWidths[$0] == max }.first ?? 0
        return labels[maxIndex]
    }
}

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
