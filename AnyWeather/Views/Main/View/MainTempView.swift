//
//  MainTempView.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainTempView: CustomView {
    private let containerView: UIView = UIView().containerStyle()
    private let cityLabel: UILabel = UILabel()
    private let descLabel: UILabel = UILabel()
    private let tempLabel: UILabel = UILabel()
    
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
        
        updateLayoutWithLabelWidth()
    }
    
    private func updateLayoutWithLabelWidth() {
        let labels: [UILabel] = [cityLabel, descLabel, tempLabel]
        let maxLabel: UILabel = getMaxIndexLabel(labels)
        maxLabel.equalToLeading(toAnchor: containerView.leadingAnchor)
        maxLabel.equalToTrailing(toAnchor: containerView.trailingAnchor)
    }
    
    override func configureAutolayouts() {
        addSubview(containerView)
        [cityLabel, descLabel, tempLabel].forEach { containerView.addSubview($0) }
        
        containerView.equalToCenter(to: self)
        
        let superView: UIView = containerView
        cityLabel.equalToTop(toAnchor: superView.topAnchor)
        cityLabel.equalToCenterX(xAnchor: superView.centerXAnchor)
        
        descLabel.equalToTop(toAnchor: cityLabel.bottomAnchor, offset: 10.adjusted)
        descLabel.equalToCenterX(xAnchor: superView.centerXAnchor)
        
        tempLabel.equalToTop(toAnchor: descLabel.bottomAnchor, offset: 10.adjusted)
        tempLabel.equalToBottom(toAnchor: superView.bottomAnchor)
        tempLabel.equalToCenterX(xAnchor: superView.centerXAnchor)
    }
}

