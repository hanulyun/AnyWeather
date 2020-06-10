//
//  UIScrollView+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension UIScrollView {
    func basicStyle(backColor: UIColor = .clear) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = backColor
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
}
