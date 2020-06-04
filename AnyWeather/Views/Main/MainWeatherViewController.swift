//
//  ViewController.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainWeatherViewController: BaseViewController {
    
    private let scrollView: UIScrollView = UIScrollView().basicStyle()
    private let yStackView: UIStackView = UIStackView().basicStyle(.vertical)
    
    private let tempView: MainTempView = MainTempView()
    private let todaySummaryView: TodaySummaryView = TodaySummaryView()
    
    private let lineView1: UIView = UIView().lineStyle(color: .black)
    private let timeWeatherView: TimeWeatherView = TimeWeatherView()
    private let lineView2: UIView = UIView().lineStyle(color: .black)
    
    private let subScrollView: UIScrollView = UIScrollView().basicStyle()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // lat: 51.51, lon: -0.13)
//        APIManager.shared
//            .request(CurrentModel.self, url: Urls.current, param: ["q": "seoul"]) { model in
//                Log.debug("model = \(model)")
//
//        }
        
        
    }
    
    override func configureAutolayouts() {
        view.addSubview(scrollView)
        scrollView.addSubview(yStackView)
        
        scrollView.equalToGuides(guide: self.guide)
        
        yStackView.equalToEdges(to: scrollView)
        yStackView.equalToWidth(Sizes.screenWidth)
        
        configureYStackView()
    }
}

extension MainWeatherViewController {
    private func configureYStackView() {
        [tempView,
         todaySummaryView,
         lineView1,
         timeWeatherView,
         lineView2,
         weekView].forEach { yStackView.addArrangedSubview($0) }
        
        tempView.equalToHeight(300.adjusted)
        tempView.setData()
        
        todaySummaryView.equalToHeight(45.adjusted)
        todaySummaryView.setData()
        
        timeWeatherView.equalToHeight(120.adjusted)
        
        weekView.equalToHeight(600.adjusted)
        weekView.backgroundColor = .orange
        
        [lineView1, lineView2].forEach { $0.equalToHeight(1.adjusted) }
    }
}
