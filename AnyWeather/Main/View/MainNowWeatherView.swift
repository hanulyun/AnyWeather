//
//  MainNowWeatherView.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/02.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainNowWeatherView: ModuleView, MainNamespace {
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var summaryContainerView: UIView!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    
    @IBOutlet weak var currentTempTopConstraint: NSLayoutConstraint!
    
    private var selfViewHeight: NSLayoutConstraint!
    
    func initializeUI(model: Model.Weather, viewHeight: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: CommonSizes.screenWidth).isActive = true
        if selfViewHeight == nil {
            selfViewHeight = self.heightAnchor.constraint(equalToConstant: viewHeight)
            selfViewHeight.isActive = true
        }
        
        bindData(model)
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
    
    private func bindData(_ model: Model.Weather) {
        cityLabel.text = model.city
        descLabel.text = model.current?.weather?.first?.description
        
        let temp: Int = Int(model.current?.temp ?? 0)
        tempLabel.text = "\(String(temp))\(Main.degSymbol)"
        
        let week = model.current?.dt?.timestampToString(format: "EEEE")
        weekLabel.text = week
        
        let maxTemp: Int = Int(model.daily?.first?.temp?.max ?? 0)
        maxTempLabel.text = String(maxTemp)
        
        let minTemp: Int = Int(model.daily?.first?.temp?.min ?? 0)
        minTempLabel.text = String(minTemp)
    }
}
