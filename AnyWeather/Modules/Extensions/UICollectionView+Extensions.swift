//
//  UICollectionView+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension UICollectionView {
    func basicCollectionViewStyle() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        showsHorizontalScrollIndicator = false
    }
}

extension UICollectionViewFlowLayout {
    func configureLayout(itemSize: CGSize, direction: UICollectionView.ScrollDirection) {
        self.itemSize = itemSize
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.scrollDirection = direction
    }
}
