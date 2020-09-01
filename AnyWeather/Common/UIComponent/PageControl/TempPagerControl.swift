//
//  CustomPagerControl.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class TempPagerControl: CustomTempView {
    private let stackView: UIStackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        
        self.setInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setControls(controls: [PagerControlItem]) {
        stackView.removeAllSubviews()
        
        let controlImages: [UIImageView] = controls.map { return $0.rawValue }
        controlImages.forEach { stackView.addArrangedSubview($0) }
        for imageView in controlImages {
            imageView.equalToSize(10.adjusted)
        }
        
        stackView.spacing = 5.adjusted
        stackView.distribution = .fillEqually
        stackView.alignment = .center
    }
    
    func selectIndex(_ index: Int) {
        let controls: [UIImageView] = stackView.subviews as! [UIImageView]
        for idx in controls.indices {
            controls[idx].isHighlighted = (index == idx)
        }
    }
    
    override func configureAutolayouts() {
        addSubview(stackView)
        stackView.equalToEdges(to: self)
    }
}
