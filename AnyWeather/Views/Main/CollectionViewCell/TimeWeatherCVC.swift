//
//  TimeWeatherCVC.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class TimeWeatherCVC: UICollectionViewCell {
    static let reuseIdentifer: String = "TimeWeatherCVC"
    
    private let amPmLabel: UILabel = UILabel()
    private let iconImageView: UIImageView = UIImageView()
    private let tempLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .color(.background)
        
        configureAutolayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData() {
        amPmLabel.text = "오전"
        amPmLabel.font = .font(.subSmall)
        
        tempLabel.text = "10"
        tempLabel.font = .font(.subMiddle)
        
        iconImageView.backgroundColor = .red
    }
}

extension TimeWeatherCVC {
    private func configureAutolayouts() {
        [amPmLabel, iconImageView, tempLabel].forEach { self.addSubview($0) }
        
        iconImageView.equalToCenter(to: self)
        iconImageView.equalToSize(24.adjusted)
        
        amPmLabel.equalToBottom(toAnchor: iconImageView.topAnchor, offset: -16.adjusted)
        amPmLabel.equalToCenterX(xAnchor: self.centerXAnchor)
        
        tempLabel.equalToTop(toAnchor: iconImageView.bottomAnchor, offset: 16.adjusted)
        tempLabel.equalToCenterX(xAnchor: self.centerXAnchor)
    }
}
