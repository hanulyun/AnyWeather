//
//  MainNowWeatherView.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/02.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainNowWeatherView: CustomView, MainNamespace {
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var summaryContainerView: UIView!
    @IBOutlet weak var weakLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    
    @IBOutlet weak var currentTempTopConstraint: NSLayoutConstraint!
    
    private var selfViewHeight: NSLayoutConstraint!
    
    func initializeUI(model: Model.WeatherModel, viewHeight: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: CommonSizes.screenWidth).isActive = true
        if selfViewHeight == nil {
            selfViewHeight = self.heightAnchor.constraint(equalToConstant: viewHeight)
            selfViewHeight.isActive = true
        }
    }
    
    func uiuiui(viewHeight: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: CommonSizes.screenWidth).isActive = true
        if selfViewHeight == nil {
            selfViewHeight = self.heightAnchor.constraint(equalToConstant: viewHeight)
            selfViewHeight.isActive = true
        }
    }
    
    func updateLayoutWhenScrolling(viewHeight: CGFloat) {
        selfViewHeight.constant = viewHeight
        
        let maxH: CGFloat = Model.Sizes.headerMaxH
        let minusConstant: CGFloat = (maxH - viewHeight) * 0.15
        var constant: CGFloat = 50 - minusConstant
        if constant < 0 {
            constant = 0
        } else if constant > 50 {
            constant = 50
        }
        currentTempTopConstraint.constant = constant
        
        let alpha: CGFloat = 1 - ((maxH - viewHeight) / maxH * 3)
        [tempLabel, summaryContainerView].forEach { $0.alpha = alpha }
    }
}
