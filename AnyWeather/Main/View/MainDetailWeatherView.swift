//
//  MainDetailWeatherView.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/02.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainDetailWeatherView: ModuleView, MainNamespace {
    
    @IBOutlet weak var leftMiniLabel: UILabel!
    @IBOutlet weak var leftValueLabel: UILabel!
    
    @IBOutlet weak var rightMiniLabel: UILabel!
    @IBOutlet weak var rightValueLabel: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    
    func initializeUI(model: Model.Detail, isLast: Bool) {
        leftMiniLabel.text = model.leftTitle
        rightMiniLabel.text = model.rightTitle
        
        leftValueLabel.text = model.leftValue
        rightValueLabel.text = model.rightValue
        
        lineView.isHidden = isLast
    }
}
