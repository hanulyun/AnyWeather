//
//  ListWeatherTableViewCell.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/03.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class ListWeatherTableViewCell: UITableViewCell, ListNamespace {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var gpsImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
        
    func configure(model: Model.Weather) {
        contentView.backgroundColor = UIColor.pay.getWeatherColor(model: model)
        
        let now: Date = Date()
        timeLabel.text = now.dateToString(format: "a h:mm", timeZone: model.timezone)
        
        cityLabel.text = model.city
        
        let temp: Int = Int(model.current?.temp ?? 0)
        tempLabel.text = "\(String(temp))\(List.degSymbol)"
        
        if let isGps: Bool = model.isGps {
            gpsImageView.isHidden = !isGps
        }
    }
}
