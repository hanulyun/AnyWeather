//
//  CustomPagerControl.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

enum PagerControl {
    case gps
    case dot
    
    var rawValue: UIImageView {
        switch self {
        case .gps: return UIImageView(image: #imageLiteral(resourceName: "gps_normal"), highlightedImage: #imageLiteral(resourceName: "gps_highlighted"))
        case .dot: return UIImageView(image: #imageLiteral(resourceName: "dot_normal"), highlightedImage: #imageLiteral(resourceName: "dot_highlighted"))
        }
    }
}

class CustomPagerControl: CustomView {
    private let stackView: UIStackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        
        self.setInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setControls(controls: [PagerControl]) {
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
