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
    }
}

extension WeekSummaryTVC {
    private func configureAutolayouts() {
        [weekLabel].forEach { addSubview($0) }
        
        weekLabel.equalToTop(toAnchor: self.topAnchor, offset: 5.adjusted)
        weekLabel.equalToLeading(toAnchor: self.leadingAnchor, offset: 16.adjusted)
        weekLabel.equalToBottom(toAnchor: self.bottomAnchor, offset: -5.adjusted)
    }
}
