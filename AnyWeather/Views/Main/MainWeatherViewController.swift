//
//  ViewController.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainWeatherViewController: BaseViewController {
    
    private let currentWeatherview: MainTempView = MainTempView()
    private let tableView: UITableView = UITableView()
    private let footerView: FooterView = FooterView()

    let maxH: CGFloat = MainSizes.currentMaxHeight
    let minH: CGFloat = MainSizes.currentMinHeight
    
    var topHeight: NSLayoutConstraint!
    
    enum CellType: Int {
        case week = 0
        case todayComment = 1
        case todayDetail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // lat: 51.51, lon: -0.13)
//        APIManager.shared
//            .request(CurrentModel.self, url: Urls.current, param: ["q": "seoul"]) { model in
//                Log.debug("model = \(model)")
//
//        }
        prepareTableView()
        
        footerView.setPageControl(withOutGps: 3)
    }
    
    override func bindData() {
        currentWeatherview.setData()
    }
    
    override func configureAutolayouts() {
        [tableView, currentWeatherview, footerView].forEach { view.addSubview($0) }
        
        viewsLayouts()
    }
    
    private func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: maxH, left: 0, bottom: 0, right: 0)
        
        tableView.register(WeekSummaryTVC.self, forCellReuseIdentifier: WeekSummaryTVC.reuseIdentifer)
        tableView.register(TodayCommentTVC.self, forCellReuseIdentifier: TodayCommentTVC.reuseIdentifer)
    }
}

extension MainWeatherViewController {
    private func viewsLayouts() {
        footerView.equalToBottom(toAnchor: guide.bottomAnchor)
        footerView.equalToLeading(toAnchor: guide.leadingAnchor)
        footerView.equalToTrailing(toAnchor: guide.trailingAnchor)
        footerView.equalToHeight(50.adjusted)
        
        tableView.equalToLeading(toAnchor: guide.leadingAnchor)
        tableView.equalToTrailing(toAnchor: guide.trailingAnchor)
        tableView.equalToTop(toAnchor: guide.topAnchor)
        tableView.equalToBottom(toAnchor: footerView.topAnchor)
        
        currentWeatherview.isUserInteractionEnabled = false
        currentWeatherview.equalToTop(toAnchor: guide.topAnchor)
        currentWeatherview.equalToLeading(toAnchor: guide.leadingAnchor)
        currentWeatherview.equalToTrailing(toAnchor: guide.trailingAnchor)
        if topHeight == nil {
            topHeight = currentWeatherview.heightAnchor.constraint(equalToConstant: maxH)
            topHeight.isActive = true
        }
        
        view.layoutIfNeeded()
    }
}

extension MainWeatherViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 9 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case CellType.week.rawValue:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: WeekSummaryTVC.reuseIdentifer, for: indexPath)
                    as? WeekSummaryTVC else { fatalError("Fail") }
            cell.setData()
            return cell
        case CellType.todayComment.rawValue:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: TodayCommentTVC.reuseIdentifer, for: indexPath) as? TodayCommentTVC else { fatalError("Fail") }
            cell.setData()
            return cell
        default:
            return UITableViewCell()
        }
            
    }
}

extension MainWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return (section == 0) ? TimeWeatherView() : nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 130.adjusted : 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = scrollView.contentOffset.y
        let tempH: CGFloat = maxH - (offsetY + maxH)
        let height: CGFloat = min(max(tempH, minH), maxH * 1.5)
        
        DispatchQueue.main.async {
            self.topHeight.constant = height
            
            if offsetY < -self.maxH {
                scrollView.contentInset = UIEdgeInsets(top: self.maxH, left: 0, bottom: 0, right: 0)
            } else {
                scrollView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
            }
            
            self.currentWeatherview.updateLayoutWhenScroll(viewHeight: height)
        }
        
        //        Log.debug("offsetY = \(offsetY)")
    }
}
