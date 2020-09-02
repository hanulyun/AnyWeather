//
//  MainDailyWeatherView.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/02.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainDailyWeatherView: CustomView, MainNamespace {
    
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var iconImageView: CustomImageView!

    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    
    func initializeUI(model: Model.Weather.Daily?) {
        let week: String? = model?.dt?.timestampToString(format: "EEEE")
        weekLabel.text = week
        
        iconImageView.loadImageUrl(model?.weather?.first?.icon)
        
        let max: Int = Int(model?.temp?.max ?? 0)
        maxTempLabel.text = max.description
        
        let min: Int = Int(model?.temp?.min ?? 0)
        minTempLabel.text = min.description
    }
}
