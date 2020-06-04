//
//  MainTempView.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainTempView: CustomView {
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
        cityLabel.font = UIFont.systemFont(ofSize: 30)
        
        descLabel.text = "30303030"
        descLabel.font = UIFont.systemFont(ofSize: 15)
        
        tempLabel.text = "29"
        tempLabel.font = UIFont.systemFont(ofSize: 60)
    }
    
    override func configureAutolayouts() {
        [cityLabel, descLabel, tempLabel].forEach { addSubview($0) }
        
        cityLabel.equalToTop(toAnchor: self.topAnchor)
        cityLabel.equalToCenterX(to: self)
        
        descLabel.equalToTop(toAnchor: cityLabel.bottomAnchor, offset: 10)
        descLabel.equalToCenterX(to: self)
        
        tempLabel.equalToTop(toAnchor: descLabel.bottomAnchor, offset: 10)
        tempLabel.equalToBottom(toAnchor: self.bottomAnchor)
        tempLabel.equalToCenterX(to: self)
    }
}

