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
    
    func setData() {
        commentLabel.numberOfLines = 0
        commentLabel.setFont(.font(.subSmall), color: .color(.main))
        commentLabel.text = "오늘은 대체로 어쩌구 저쩌구 내일은 어떻고 저떻고 최고 기온이 어떻고 알알알 내일은 맑을지 잘 모르겠음. 블라블라아아아아아~~~ 블라아아아"
    }
    
    override func configureAutolayouts() {
        [commentLabel, lineView1, lineView2].forEach { addSubview($0) }
        
        commentLabel.equalToTop(toAnchor: self.topAnchor, offset: 16.adjusted)
        commentLabel.equalToLeading(toAnchor: self.leadingAnchor, offset: 16.adjusted)
        commentLabel.equalToTrailing(toAnchor: self.trailingAnchor, offset: -16.adjusted)
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
