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
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    private let maxTempLabel: UILabel = UILabel()
    private let minTempLabel: UILabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        self.setInit(.lightGray)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureAutolayouts() {
        [weekLabel, todayLabel, maxTempLabel, minTempLabel].forEach { addSubview($0) }
        
        weekLabel.equalToTop(toAnchor: self.topAnchor, offset: 8)
        weekLabel.equalToLeading(toAnchor: self.leadingAnchor, offset: 16)
        
    }
}
