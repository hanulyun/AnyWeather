//
//  MainViewController.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {
    
    private let hScrollView: UIScrollView = UIScrollView().basicStyle()
    private let hStackView: UIStackView = UIStackView().basicStyle(.horizontal)
    
    private let footerView: FooterView = FooterView()
    
    private let viewModel: MainWeatherViewModel = MainWeatherViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bindData() {
        footerView.setPageControl(withOutGps: 3)
        
        viewModel.requestCurrentGps { [weak self] model in
            if let model: CurrentModel = model {
                DispatchQueue.main.async {
//                    self?.currentWeatherview.setData(model: model)
                    for _ in 0..<3 {
                        let fullView = MainFullView()
                        fullView.setData(model: model)
                        self?.hStackView.addArrangedSubview(fullView)
                    }
                }
            }
        }
    }
    
    override func configureAutolayouts() {
        [hScrollView, footerView].forEach { view.addSubview($0) }
        hScrollView.addSubview(hStackView)
        
        hScrollView.equalToGuides(guide: self.guide)
        
        hStackView.equalToEdges(to: hScrollView)
        hStackView.equalToBottom(toAnchor: footerView.topAnchor)
        
        footerView.equalToBottom(toAnchor: guide.bottomAnchor)
        footerView.equalToLeading(toAnchor: guide.leadingAnchor)
        footerView.equalToTrailing(toAnchor: guide.trailingAnchor)
        footerView.equalToHeight(50.adjusted)
    }
}
