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
    
    var cModels: [CurrentModel] = [CurrentModel]()
    var models = [WeatherModel]() {
        didSet {
            DispatchQueue.main.async {
                self.footerView.setPageControl(withOutGps: self.models.count - 1)
                self.changeBackColor(model: self.models.first)
                    
                self.hStackView.removeAllSubviews()
                for model in self.models {
                    let fullView = MainFullView()
                    fullView.setData(model: model)
                    self.hStackView.addArrangedSubview(fullView)
                }
            }
        }
    }
    
    var currentIndex: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.footerView.selectedPage(self.currentIndex)
                self.changeBackColor(model: self.models[self.currentIndex])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonEvent()
    }
    
    override func bindData() {
        viewModel.requestCurrentGps()
        viewModel.requestSavedLocation()
                
        viewModel.currentModels = { [weak self] models in
            self?.models = models
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
        footerView.listContainerButton.addTarget(self, action: #selector(listButtonTap), for: .touchUpInside)
    }
    
    @objc func listButtonTap() {
        let vc: ListViewController = ListViewController(viewModel: self.viewModel)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    private func changeBackColor(model: WeatherModel?) {
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = .getWeatherColor(model?.current?.weather?.first?.id)
        }
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber: CGFloat = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let index: Int = Int(pageNumber)
        self.currentIndex = index
    }
}

extension MainViewController: ListViewContollerDelegate {
    func selectedIndex(index: Int) {
        self.currentIndex = index
        let xOffset: CGFloat = CommonSizes.screenWidth * CGFloat(index)
        hScrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
    }
    
    func changeWeatherList(isChanged: Bool) {
        
    }
}
