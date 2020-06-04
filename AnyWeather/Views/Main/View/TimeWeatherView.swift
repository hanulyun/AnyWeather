//
//  TimeWeatherView.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class TimeWeatherView: CustomView {
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.basicCollectionViewStyle()

        collectionView.register(TimeWeatherCVC.self, forCellWithReuseIdentifier: TimeWeatherCVC.reuseIdentifer)

        return collectionView
    }()
    
    init() {
        super.init(frame: .zero)
        
        self.setInit(.red)
        
        configureAutolayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureAutolayouts() {
        configureCollectionView()
        
        addSubview(collectionView)
        collectionView.equalToEdges(to: self)
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let itemSize: CGSize = CGSize(width: 80.adjusted, height: 120.adjusted)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.configureLayout(itemSize: itemSize, direction: .horizontal)
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
}

extension TimeWeatherView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: TimeWeatherCVC.reuseIdentifer, for: indexPath)
            as? TimeWeatherCVC else { fatalError("Failed to cast TimeWeatherCVC") }
        cell.setData()
        return cell
    }
}

extension TimeWeatherView: UICollectionViewDelegate {
    
}
