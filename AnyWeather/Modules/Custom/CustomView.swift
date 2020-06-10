//
//  CustomView.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class CustomView: UIView, ViewProtocol {
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
