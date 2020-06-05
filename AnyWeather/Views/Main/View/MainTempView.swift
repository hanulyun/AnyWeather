//
//  MainTempView.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainTempView: CustomView {
    private let centerContainerView: UIView = UIView().containerStyle()
    private let cityLabel: UILabel = UILabel()
    private let descLabel: UILabel = UILabel()
    private let tempLabel: UILabel = UILabel()
    
    private let summaryContainerView: UIView = UIView().containerStyle()
    private let weekLabel: UILabel = UILabel()
    private let todayLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘"
        label.font = .font(.subSmall)
        return label
    }()
    private let maxTempLabel: UILabel = UILabel()
    private let minTempLabel: UILabel = UILabel()
    
    private var centerTopConstraint: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        
        self.setInit(.yellow)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData() {
        cityLabel.text = "City"
        cityLabel.font = .font(.mainMiddle)
        cityLabel.backgroundColor = .red
        
        descLabel.text = "30303030"
        descLabel.font = .font(.subSmall)
        descLabel.backgroundColor = .brown
        
        tempLabel.text = "29"
        tempLabel.font = .font(.mainBig)
        tempLabel.backgroundColor = .cyan
        
        weekLabel.text = "수요일"
        weekLabel.font = .font(.subMiddle)
        
        maxTempLabel.text = "30"
        maxTempLabel.font = .font(.subMiddle)
        
        minTempLabel.text = "20"
        minTempLabel.font = .font(.subMiddle)
        
        updateLayoutWithLabelWidth()
    }
    
    func updateLayoutWhenScroll(viewHeight: CGFloat) {
        let maxH: CGFloat = MainSizes.currentMaxHeight
        let minusConst: CGFloat = (maxH - viewHeight) * 0.15
        var constant: CGFloat = 50.adjusted - minusConst
        if constant < 0 {
            constant = 0
        }
        centerTopConstraint.constant = constant
        
        let alpha = 1 - ((maxH - viewHeight) / maxH * 2)
        tempLabel.alpha = alpha
        Log.debug("alpha = \(alpha)")
    }
    
    private func updateLayoutWithLabelWidth() {
        let labels: [UILabel] = [cityLabel, descLabel, tempLabel]
        let maxLabel: UILabel = getMaxIndexLabel(labels)
        maxLabel.equalToLeading(toAnchor: centerContainerView.leadingAnchor)
        maxLabel.equalToTrailing(toAnchor: centerContainerView.trailingAnchor)
    }
    
    override func configureAutolayouts() {
        [centerContainerView, summaryContainerView].forEach { addSubview($0) }
        [cityLabel, descLabel, tempLabel].forEach { centerContainerView.addSubview($0) }
        
        if centerTopConstraint == nil {
            centerTopConstraint
                = centerContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50.adjusted)
            centerTopConstraint.isActive = true
        }
        centerContainerView.equalToCenterX(xAnchor: self.centerXAnchor)
        
        let superView: UIView = centerContainerView
        cityLabel.equalToTop(toAnchor: superView.topAnchor)
        cityLabel.equalToCenterX(xAnchor: superView.centerXAnchor)
        
        descLabel.equalToTop(toAnchor: cityLabel.bottomAnchor, offset: 10.adjusted)
        descLabel.equalToCenterX(xAnchor: superView.centerXAnchor)
        
        tempLabel.equalToTop(toAnchor: descLabel.bottomAnchor, offset: 10.adjusted)
        tempLabel.equalToBottom(toAnchor: superView.bottomAnchor)
        tempLabel.equalToCenterX(xAnchor: superView.centerXAnchor)
    }
}

