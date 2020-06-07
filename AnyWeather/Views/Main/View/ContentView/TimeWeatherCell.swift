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
    
    private let lineView1: UIView = UIView().filledStyle(color: .color(.translucentMain))
    private let lineView2: UIView = UIView().filledStyle(color: .color(.translucentMain))
    
    init() {
        super.init(frame: .zero)
        
        setInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(model: WeatherModel.Hourly?, isFirst: Bool = false) {
        let time = isFirst ? "지금" : model?.dt?.timestampToString(format: "a h시")
        amPmLabel.text = time
        amPmLabel.setFont(.font(.subSmall), color: .color(.main))
        
        tempLabel.text = Int(model?.temp ?? 0).description + degSymbol
        tempLabel.setFont(.font(.subMiddle), color: .color(.main))
        
        iconImageView.backgroundColor = .blue
    }
    
    override func configureAutolayouts() {
        addSubview(containerView)
        [amPmLabel, iconImageView, tempLabel, lineView1, lineView2].forEach { containerView.addSubview($0) }
        
        containerView.equalToEdges(to: self)
        containerView.equalToHeight(130.adjusted)
        containerView.equalToWidth(80.adjusted)
        
        iconImageView.equalToCenter(to: self)
        iconImageView.equalToSize(24.adjusted)
        
        amPmLabel.equalToBottom(toAnchor: iconImageView.topAnchor, offset: -16.adjusted)
        amPmLabel.equalToCenterX(xAnchor: self.centerXAnchor)
        
        tempLabel.equalToTop(toAnchor: iconImageView.bottomAnchor, offset: 16.adjusted)
        tempLabel.equalToCenterX(xAnchor: self.centerXAnchor)
        
        lineView1.equalToLeading(toAnchor: containerView.leadingAnchor)
        lineView1.equalToTrailing(toAnchor: containerView.trailingAnchor)
        lineView1.equalToTop(toAnchor: containerView.topAnchor)
        lineView1.equalToHeight(1)
        
        lineView2.equalToLeading(toAnchor: containerView.leadingAnchor)
        lineView2.equalToTrailing(toAnchor: containerView.trailingAnchor)
        lineView2.equalToBottom(toAnchor: containerView.bottomAnchor)
        lineView2.equalToHeight(1)
    }
}
