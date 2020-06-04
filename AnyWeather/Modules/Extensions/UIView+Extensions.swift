//
//  UIView+Extensions.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension UIView {
    private func prepareConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func equalToEdges(to: UIView) {
        prepareConstraints()
        let edges: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: to.topAnchor),
            leadingAnchor.constraint(equalTo: to.leadingAnchor),
            trailingAnchor.constraint(equalTo: to.trailingAnchor),
            bottomAnchor.constraint(equalTo: to.bottomAnchor)
        ]
        edges.forEach { $0.isActive = true }
    }
    
    func equalToGuides(guide: UILayoutGuide) {
        prepareConstraints()
        let edges: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: guide.topAnchor),
            leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ]
        edges.forEach { $0.isActive = true }
    }
    
    func equalToCenter(to: UIView) {
        prepareConstraints()
        let center: [NSLayoutConstraint] = [
            centerXAnchor.constraint(equalTo: to.centerXAnchor),
            centerYAnchor.constraint(equalTo: to.centerYAnchor)
        ]
        center.forEach { $0.isActive = true }
    }
    
    func equalToSize(_ size: CGFloat) {
        prepareConstraints()
        let size: [NSLayoutConstraint] = [
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size)
        ]
        size.forEach { $0.isActive = true }
    }
    
    func equalToCenterX(xAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, offset: CGFloat = 0) {
        prepareConstraints()
        centerXAnchor.constraint(equalTo: xAnchor, constant: offset).isActive = true
    }
    
    func equalToCenterY(yAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, offset: CGFloat = 0) {
        prepareConstraints()
        centerYAnchor.constraint(equalTo: yAnchor, constant: offset).isActive = true
    }
    
    func equalToLeading(toAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, offset: CGFloat = 0) {
        prepareConstraints()
        leadingAnchor.constraint(equalTo: toAnchor, constant: offset).isActive = true
    }
    
    func equalToTrailing(toAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, offset: CGFloat = 0) {
        prepareConstraints()
        trailingAnchor.constraint(equalTo: toAnchor, constant: offset).isActive = true
    }
    
    func equalToTop(toAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, offset: CGFloat = 0) {
        prepareConstraints()
        topAnchor.constraint(equalTo: toAnchor, constant: offset).isActive = true
    }
    
    func equalToBottom(toAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, offset: CGFloat = 0) {
        prepareConstraints()
        bottomAnchor.constraint(equalTo: toAnchor, constant: offset).isActive = true
    }
    
    func equalToWidth(_ width: CGFloat) {
        prepareConstraints()
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func equalToHeight(_ height: CGFloat) {
        prepareConstraints()
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func containerStyle() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }
    
    func lineStyle(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
}
