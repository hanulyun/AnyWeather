//
//  UIStackView+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension UIStackView {
    func basicStyle(_ axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }
    
    func removeAllSubviews() {
        if self.subviews.count > 0 {
            self.subviews.forEach { self.removeArrangedSubview($0) }
        }
    }
}
