//
//  ViewController.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainWeatherViewController: BaseViewController {
    
    let currentWeatherview: MainTempView = MainTempView()
    private let tableView: UITableView = UITableView()

    let maxH: CGFloat = MainSizes.currentMaxHeight
    let minH: CGFloat = MainSizes.currentMinHeight
    
    var topHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // lat: 51.51, lon: -0.13)
//        APIManager.shared
//            .request(CurrentModel.self, url: Urls.current, param: ["q": "seoul"]) { model in
//                Log.debug("model = \(model)")
//
//        }
        prepareTableView()
    }
    
    override func bindData() {
        currentWeatherview.setData()
    }
    
    override func configureAutolayouts() {
        view.addSubview(tableView)
        view.addSubview(currentWeatherview)
        
        tableView.equalToGuides(guide: self.guide)
        tableView.contentInset = UIEdgeInsets(top: maxH, left: 0, bottom: 0, right: 0)
        currentWeatherview.isUserInteractionEnabled = false
        
        currentWeatherview.equalToTop(toAnchor: self.guide.topAnchor)
        currentWeatherview.equalToLeading(toAnchor: self.guide.leadingAnchor)
        currentWeatherview.equalToTrailing(toAnchor: self.guide.trailingAnchor)
        if topHeight == nil {
            topHeight = currentWeatherview.heightAnchor.constraint(equalToConstant: maxH)
            topHeight.isActive = true
        }
        
        view.layoutIfNeeded()
    }
    
    private func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(WeekSummaryTVC.self, forCellReuseIdentifier: WeekSummaryTVC.reuseIdentifer)
    }
}

extension MainWeatherViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: WeekSummaryTVC.reuseIdentifer, for: indexPath) as? WeekSummaryTVC else { fatalError("Fail") }
            cell.setData()
            return cell
    }
}

extension MainWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TimeWeatherView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 130.adjusted
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let y = maxH - (offsetY + maxH)
        let height = min(max(y, minH), maxH * 1.5)
        topHeight.constant = height
        
        if offsetY < -maxH {
            scrollView.contentInset = UIEdgeInsets(top: maxH, left: 0, bottom: 0, right: 0)
        } else {
            scrollView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        }
        
        currentWeatherview.updateLayoutWhenScroll(viewHeight: height)
        
        //        Log.debug("offsetY = \(offsetY)")
    }
}
