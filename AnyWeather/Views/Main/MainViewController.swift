//
//  MainViewController.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

public var scrollY: CGFloat = 0

class MainViewController: BaseViewController {
    
    lazy var hScrollView: UIScrollView = {
        let scrollView = UIScrollView().basicStyle()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    private let hStackView: UIStackView = UIStackView().basicStyle(.horizontal)
    
    private let footerView: FooterView = FooterView()
    
    private let viewModel: MainWeatherViewModel = MainWeatherViewModel()
    
    var models = [CurrentModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonEvent()
    }
    
    override func bindData() {
        footerView.setPageControl(withOutGps: 3)
        
        viewModel.requestCurrentGps { [weak self] model in
            if let model: CurrentModel = model {
                
                DispatchQueue.main.async {
                    self?.hStackView.removeAllSubviews()
                    for _ in 0..<4 {
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
    
    private func buttonEvent() {
        footerView.listButton.addTarget(self, action: #selector(listButtonTap), for: .touchUpInside)
    }
    
    @objc func listButtonTap() {
        bindData()
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        footerView.selectedPage(Int(pageNumber))
    }
}
