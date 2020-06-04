//
//  TodaySummaryView.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class TodaySummaryView: CustomView {
    private let weekLabel: UILabel = UILabel()
    private let todayLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘"
        label.font = .font(.subSmall)
        return label
    }()
    private let maxTempLabel: UILabel = UILabel()
    private let minTempLabel: UILabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        self.setInit(.darkGray)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData() {
        weekLabel.text = "수요일"
        weekLabel.font = .font(.subMiddle)
        
        maxTempLabel.text = "30"
        maxTempLabel.font = .font(.subMiddle)
        
        minTempLabel.text = "20"
        minTempLabel.font = .font(.subMiddle)
    }
    
    override func configureAutolayouts() {
        [weekLabel, todayLabel, maxTempLabel, minTempLabel].forEach { addSubview($0) }
        
        weekLabel.equalToCenterY(yAnchor: self.centerYAnchor)
        weekLabel.equalToLeading(toAnchor: self.leadingAnchor, offset: 16.adjusted)
        
        todayLabel.equalToLeading(toAnchor: weekLabel.trailingAnchor, offset: 8.adjusted)
        todayLabel.equalToBottom(toAnchor: weekLabel.bottomAnchor)
        
        minTempLabel.equalToTrailing(toAnchor: self.trailingAnchor, offset: -16.adjusted)
        minTempLabel.equalToCenterY(yAnchor: self.centerYAnchor)
        
        maxTempLabel.equalToTrailing(toAnchor: minTempLabel.leadingAnchor, offset: -16.adjusted)
        maxTempLabel.equalToCenterY(yAnchor: self.centerYAnchor)
    }
}
