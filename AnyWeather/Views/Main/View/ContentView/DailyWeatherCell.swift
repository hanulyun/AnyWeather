//
//  DailyWeatherCell.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class DailyWeatherCell: CustomView {
    
    private let containerView: UIView = UIView()
    
    private let weekLabel: UILabel = UILabel()
    private let iconImageView: CustomImageView = CustomImageView()
    private let maxTempLabel: UILabel = UILabel()
    private let minTempLabel: UILabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        setInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(model: WeatherModel.Daily?) {
        let week: String? = model?.dt?.timestampToString(format: "EEEE")
        weekLabel.text = week
        weekLabel.setFont(.font(.subMiddle), color: .color(.main))
        
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.loadImageUrl(model?.weather?.first?.icon)
        
        let max: Int = Int(model?.temp?.max ?? 0)
        maxTempLabel.text = max.description
        maxTempLabel.setFont(.font(.subMiddle), color: .color(.main))
        
        let min: Int = Int(model?.temp?.min ?? 0)
        minTempLabel.text = min.description
        minTempLabel.setFont(.font(.subMiddle), color: .color(.translucentMain))
    }
    
    override func configureAutolayouts() {
        addSubview(containerView)
        [weekLabel, iconImageView, maxTempLabel, minTempLabel].forEach { containerView.addSubview($0) }
        
        containerView.equalToEdges(to: self)
        
        let superView: UIView = containerView
        weekLabel.equalToTop(toAnchor: superView.topAnchor, offset: 8.adjusted)
        weekLabel.equalToLeading(toAnchor: superView.leadingAnchor, offset: 16.adjusted)
        weekLabel.equalToBottom(toAnchor: superView.bottomAnchor, offset: -8.adjusted)
        
        iconImageView.equalToCenter(to: superView)
        iconImageView.equalToSize(36.adjusted)
        
        minTempLabel.equalToCenterY(yAnchor: weekLabel.centerYAnchor)
        minTempLabel.equalToTrailing(toAnchor: superView.trailingAnchor, offset: -16.adjusted)
        
        maxTempLabel.equalToCenterY(yAnchor: weekLabel.centerYAnchor)
        maxTempLabel.equalToTrailing(toAnchor: minTempLabel.leadingAnchor, offset: -24.adjusted)
    }
}
