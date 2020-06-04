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
    
    func equalToCenterX(to: UIView, offset: CGFloat = 0) {
        prepareConstraints()
        centerXAnchor.constraint(equalTo: to.centerXAnchor, constant: offset).isActive = true
    }
    
    func equalToCenterY(to: UIView, offset: CGFloat = 0) {
        prepareConstraints()
        centerYAnchor.constraint(equalTo: to.centerYAnchor, constant: offset).isActive = true
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
}
