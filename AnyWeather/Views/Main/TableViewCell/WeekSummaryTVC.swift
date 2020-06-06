//
//  WeekWeatherSummaryTVC.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class WeekSummaryTVC: UITableViewCell {
    static let reuseIdentifer: String = "WeekSummaryTVC"
    
    private let weekLabel: UILabel = UILabel()
    private let iconImageView: UIImageView = UIImageView()
    private let maxTempLabel: UILabel = UILabel()
    private let minTempLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .blue
        selectionStyle = .none
        
        configureAutolayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData() {
        weekLabel.text = "수요일"
        weekLabel.font = .font(.subMiddle)
        
        iconImageView.backgroundColor = .cyan
        
        maxTempLabel.text = "20"
        maxTempLabel.font = .font(.subMiddle)
        
        minTempLabel.text = "8"
        minTempLabel.setFont(.font(.subMiddle), color: .color(.translucentMain))
    }
}

extension WeekSummaryTVC {
    private func configureAutolayouts() {
        [weekLabel, iconImageView, maxTempLabel, minTempLabel].forEach { addSubview($0) }
        
        weekLabel.equalToTop(toAnchor: self.topAnchor, offset: 8.adjusted)
        weekLabel.equalToLeading(toAnchor: self.leadingAnchor, offset: 16.adjusted)
        weekLabel.equalToBottom(toAnchor: self.bottomAnchor, offset: -8.adjusted)
        
        iconImageView.equalToCenter(to: self)
        iconImageView.equalToSize(24.adjusted)
        
        minTempLabel.equalToCenterY(yAnchor: weekLabel.centerYAnchor)
        minTempLabel.equalToTrailing(toAnchor: self.trailingAnchor, offset: -16.adjusted)
        
        maxTempLabel.equalToCenterY(yAnchor: weekLabel.centerYAnchor)
        maxTempLabel.equalToTrailing(toAnchor: minTempLabel.leadingAnchor, offset: -24.adjusted)
    }
}
