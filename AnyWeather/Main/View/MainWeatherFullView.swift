//
//  MainWeatherFullView.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainWeatherFullView: CustomView, MainNamespace {
    
    @IBOutlet weak var nowWeatherView: UIView!
    @IBOutlet weak var hourlyHStackView: UIStackView!
    
    @IBOutlet weak var contentVScrollView: UIScrollView!
    @IBOutlet weak var contentMaskView: UIView!
    
    @IBOutlet weak var contentView: UIView!
//    @IBOutlet weak var dailyStackView: UIStackView!
//    @IBOutlet weak var todaySummaryLabel: UILabel!
//    @IBOutlet weak var todayDetailStackView: UIStackView!
    
    @IBOutlet weak var nowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var maskTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
    
    private lazy var mainNowWeatherView = MainNowWeatherView.instantiate()
    
    override class func instantiate() -> Self {
        let view = loadFromNib(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: CommonSizes.screenWidth).isActive = true
        return view
    }
    
    func tempSet() {
        contentVScrollView.delegate = self
        nowWeatherView.addSubview(mainNowWeatherView)
        mainNowWeatherView.uiuiui(viewHeight: nowHeightConstraint.constant)
    }
    
    func initializeUI(model: Model.WeatherModel) {
        
        contentVScrollView.delegate = self
        
        initializeNowWeatherView(model: model)
        
//        todaySummaryLabel.text = """
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        d
//        000000
//"""
    }
    
    private func initializeNowWeatherView(model: Model.WeatherModel) {
        nowWeatherView.addSubview(mainNowWeatherView)
        mainNowWeatherView.initializeUI(model: model, viewHeight: nowHeightConstraint.constant)
    }
}

extension MainWeatherFullView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY: CGFloat = scrollView.contentOffset.y
        let scrollUpOffsetY: CGFloat = Model.Sizes.headerMaxH - offSetY
        
        if scrollUpOffsetY <= Model.Sizes.headerMinH {
            nowHeightConstraint.constant = Model.Sizes.headerMinH
            maskTopConstraint.constant = Model.Sizes.headerMinH + Model.Sizes.hourlyWeatherH
            contentTopConstraint.constant = (Model.Sizes.headerMaxH - Model.Sizes.headerMinH) - offSetY
        } else {
            nowHeightConstraint.constant = scrollUpOffsetY
            maskTopConstraint.constant = Model.Sizes.fullHeaderH - offSetY
            contentTopConstraint.constant = 0
        }
        
        mainNowWeatherView.updateLayoutWhenScrolling(viewHeight: nowHeightConstraint.constant)
    }
}
