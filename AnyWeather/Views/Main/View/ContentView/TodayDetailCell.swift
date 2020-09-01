//
//  TodayDetailView.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class TodayDetailCell: CustomTempView {
    
    private let miniLabel1: UILabel = UILabel()
    private let valueLabel1: UILabel = UILabel()
    
    private let miniLabel2: UILabel = UILabel()
    private let valueLabel2: UILabel = UILabel()
    
    private let lineView: UIView = UIView().filledStyle(color: .color(.translucentMain))
    
    init() {
        super.init(frame: .zero)
        
        setInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(model: DetailModel, isLast: Bool) {
        miniLabel1.text = model.title1
        miniLabel1.setFont(.font(.subTiny), color: .color(.translucentMain))
        
        miniLabel2.text = model.title2
        miniLabel2.setFont(.font(.subTiny), color: .color(.translucentMain))
        
        valueLabel1.text = model.value1
        valueLabel1.setFont(.font(.subBig), color: .color(.main))
        
        valueLabel2.text = model.value2
        valueLabel2.setFont(.font(.subBig), color: .color(.main))
        
        lineView.isHidden = isLast
    }
    
    override func configureAutolayouts() {
        [miniLabel1, miniLabel2, valueLabel1, valueLabel2, lineView].forEach { addSubview($0) }
        
        miniLabel1.equalToTop(toAnchor: self.topAnchor, offset: 8.adjusted)
        miniLabel1.equalToLeading(toAnchor: self.leadingAnchor, offset: 16.adjusted)
        
        valueLabel1.equalToTop(toAnchor: miniLabel1.bottomAnchor, offset: 4.adjusted)
        valueLabel1.equalToLeading(toAnchor: miniLabel1.leadingAnchor)
        valueLabel1.equalToBottom(toAnchor: self.bottomAnchor, offset: -8.adjusted)
        
        miniLabel2.equalToLeading(toAnchor: self.centerXAnchor, offset: 0)
        miniLabel2.equalToCenterY(yAnchor: miniLabel1.centerYAnchor)
        
        valueLabel2.equalToLeading(toAnchor: miniLabel2.leadingAnchor)
        valueLabel2.equalToCenterY(yAnchor: valueLabel1.centerYAnchor)
        
        lineView.equalToLeading(toAnchor: self.leadingAnchor, offset: 16.adjusted)
        lineView.equalToTrailing(toAnchor: self.trailingAnchor, offset: -16.adjusted)
        lineView.equalToBottom(toAnchor: self.bottomAnchor)
        lineView.equalToHeight(1)
    }
}
