//
//  TimeWeatherCell.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class TimeWeatherCell: CustomView {
    
    private let containerView: UIView = UIView()
    
    private let amPmLabel: UILabel = UILabel()
    private let iconImageView: UIImageView = UIImageView()
    private let tempLabel: UILabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        setInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData() {
        amPmLabel.text = "오전"
        amPmLabel.font = .font(.subSmall)
        
        tempLabel.text = "10"
        tempLabel.font = .font(.subMiddle)
        
        iconImageView.backgroundColor = .blue
    }
    
    override func configureAutolayouts() {
        addSubview(containerView)
        [amPmLabel, iconImageView, tempLabel].forEach { containerView.addSubview($0) }
        
        containerView.equalToEdges(to: self)
        containerView.equalToHeight(130.adjusted)
        containerView.equalToWidth(80.adjusted)
        
        iconImageView.equalToCenter(to: self)
        iconImageView.equalToSize(24.adjusted)
        
        amPmLabel.equalToBottom(toAnchor: iconImageView.topAnchor, offset: -16.adjusted)
        amPmLabel.equalToCenterX(xAnchor: self.centerXAnchor)
        
        tempLabel.equalToTop(toAnchor: iconImageView.bottomAnchor, offset: 16.adjusted)
        tempLabel.equalToCenterX(xAnchor: self.centerXAnchor)
    }
}
