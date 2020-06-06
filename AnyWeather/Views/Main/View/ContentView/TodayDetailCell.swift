//
//  TodayDetailView.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class TodayDetailCell: CustomView {
    
    private let miniLabel1: UILabel = UILabel()
    private let valueLabel1: UILabel = UILabel()
    
    private let miniLabel2: UILabel = UILabel()
    private let valueLabel2: UILabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        setInit(UIColor.yellow.withAlphaComponent(0.5))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData() {
        miniLabel1.text = "일출"
        miniLabel1.setFont(.font(.subTiny), color: .color(.translucentMain))
        
        miniLabel2.text = "일몰"
        miniLabel2.setFont(.font(.subTiny), color: .color(.translucentMain))
        
        valueLabel1.text = "오전 00시"
        valueLabel1.setFont(.font(.subBig), color: .color(.main))
        
        valueLabel2.text = "오후 00시"
        valueLabel2.setFont(.font(.subBig), color: .color(.main))
    }
    
    override func configureAutolayouts() {
        [miniLabel1, miniLabel2, valueLabel1, valueLabel2].forEach { addSubview($0) }
        
        miniLabel1.equalToTop(toAnchor: self.topAnchor, offset: 8.adjusted)
        miniLabel1.equalToLeading(toAnchor: self.leadingAnchor, offset: 16.adjusted)
        
        valueLabel1.equalToTop(toAnchor: miniLabel1.bottomAnchor, offset: 8.adjusted)
        valueLabel1.equalToLeading(toAnchor: miniLabel1.leadingAnchor)
        valueLabel1.equalToBottom(toAnchor: self.bottomAnchor, offset: -8.adjusted)
        
        miniLabel2.equalToLeading(toAnchor: self.centerXAnchor, offset: 0)
        miniLabel2.equalToCenterY(yAnchor: miniLabel1.centerYAnchor)
        
        valueLabel2.equalToLeading(toAnchor: miniLabel2.leadingAnchor)
        valueLabel2.equalToCenterY(yAnchor: valueLabel1.centerYAnchor)
    }
}
