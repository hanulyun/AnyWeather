//
//  TodaySummaryCell.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class TodaySummaryView: CustomView {
    
    private let commentLabel: UILabel = UILabel()
    
    private let lineView1: UIView = UIView().filledStyle(color: .color(.translucentMain))
    private let lineView2: UIView = UIView().filledStyle(color: .color(.translucentMain))
    
    init() {
        super.init(frame: .zero)
        
        setInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(model: WeatherModel) {
        commentLabel.numberOfLines = 0
        commentLabel.setFont(.font(.subSmall), color: .color(.main))
        
        var comment: String = "오늘: "
        if let desc: String = model.current?.weather?.first?.description {
            comment.append(desc)
        }
        if let max: Double = model.daily?.first?.temp?.max {
            let maxInt: Int = Int(max)
            comment.append(", 최고 기온은 \(maxInt.description)\(degSymbol)입니다.")
        }
        if let min: Double = model.daily?.first?.temp?.min {
            let minInt: Int = Int(min)
            comment.append(" 최저 기온은 \(minInt.description)\(degSymbol)입니다.")
        }
        commentLabel.text = comment
    }
    
    override func configureAutolayouts() {
        [commentLabel, lineView1, lineView2].forEach { addSubview($0) }
        
        commentLabel.equalToTop(toAnchor: self.topAnchor, offset: 16.adjusted)
        commentLabel.equalToLeading(toAnchor: self.leadingAnchor, offset: 16.adjusted)
        commentLabel.equalToWidth(CommonSizes.screenWidth - 16.adjusted * 2)
        commentLabel.equalToBottom(toAnchor: self.bottomAnchor, offset: -16.adjusted)
        
        lineView1.equalToLeading(toAnchor: self.leadingAnchor)
        lineView1.equalToTrailing(toAnchor: self.trailingAnchor)
        lineView1.equalToTop(toAnchor: self.topAnchor)
        lineView1.equalToHeight(1)
        
        lineView2.equalToLeading(toAnchor: self.leadingAnchor)
        lineView2.equalToTrailing(toAnchor: self.trailingAnchor)
        lineView2.equalToBottom(toAnchor: self.bottomAnchor)
        lineView2.equalToHeight(1)
    }
}
