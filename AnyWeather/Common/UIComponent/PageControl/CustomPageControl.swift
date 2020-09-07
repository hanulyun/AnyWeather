//
//  PageControl.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

enum PagerControlItem {
    case gps
    case dot
    
    var rawValue: UIImageView {
        switch self {
        case .gps: return UIImageView(image: #imageLiteral(resourceName: "gps_normal"), highlightedImage: #imageLiteral(resourceName: "gps_highlighted"))
        case .dot: return UIImageView(image: #imageLiteral(resourceName: "dot_normal"), highlightedImage: #imageLiteral(resourceName: "dot_highlighted"))
        }
    }
}

class CustomPagerControl: ModuleView {
    
    @IBOutlet weak var controlStackView: UIStackView!
    
    func setControls(controls: [PagerControlItem]) {
        controlStackView.removeAllSubviews()
        
        let controlImages: [UIImageView] = controls.map { return $0.rawValue }
        controlImages.forEach { controlStackView.addArrangedSubview($0) }
        for imageView in controlImages {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        }
    }
    
    func selectIndex(_ index: Int) {
        let controls: [UIImageView] = controlStackView.subviews as! [UIImageView]
        for idx in controls.indices {
            controls[idx].isHighlighted = (index == idx)
        }
    }
}
