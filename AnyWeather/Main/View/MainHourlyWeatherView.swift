//
//  MainHourlyView.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/02.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import Kakaopay

class MainHourlyWeatherView: ModuleView, MainNamespace {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var ampmLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    func initializeUI(model: Model.Weather.Hourly?, isFirst: Bool) {
        let time: String = isFirst ? "지금" : "\(model?.dt?.timestampToString(format: "a h") ?? "")시"
        ampmLabel.text = time
        
        tempLabel.text = Int(model?.temp ?? 0).description + Main.degSymbol
        
        if let icon: String = model?.weather?.first?.icon {
            let url: URL? = URL(string: "\(HTTPClient.Urls.icon)\(icon).png")
            iconImageView.setImage(url: url)
        }
    }
}
