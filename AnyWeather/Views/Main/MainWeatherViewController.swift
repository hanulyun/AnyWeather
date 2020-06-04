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
    
    private let timeView: UIView = UIView()
    private let weekView: UIView = UIView()

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
        [tempView, todaySummaryView, timeView, weekView].forEach { yStackView.addArrangedSubview($0) }
        
        tempView.equalToHeight(300.adjusted)
        tempView.setData()
        
        todaySummaryView.equalToHeight(50.adjusted)
        todaySummaryView.setData()
        
        timeView.equalToHeight(120.adjusted)
        timeView.backgroundColor = .red
        
        weekView.equalToHeight(600.adjusted)
        weekView.backgroundColor = .orange
    }
}
