//
//  ViewController.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainWeatherViewController: BaseViewController {
    
    let scrollView = UIScrollView()
    
    private let currentWeatherview: MainTempView = MainTempView()
    private let tableView: UITableView = UITableView()
    private let footerView: FooterView = FooterView()
    
    let maskView = UIView()
    let contentView = UIView()

    private let viewModel: MainWeatherViewModel = MainWeatherViewModel()
    
    private let maxH: CGFloat = MainSizes.currentMaxHeight
    private let minH: CGFloat = MainSizes.currentMinHeight
    
    private var topHeight: NSLayoutConstraint!
    private var maskTop: NSLayoutConstraint!
    
    enum CellType: Int {
        case week = 0
        case todayComment = 1
        case todayDetail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        
        footerView.setPageControl(withOutGps: 3)
    }
    
    override func bindData() {
        viewModel.requestCurrentGps { [weak self] model in
            if let model: CurrentModel = model {
                DispatchQueue.main.async {
                    self?.currentWeatherview.setData(model: model)
                }
            }
        }
    }
    
    override func configureAutolayouts() {
        [currentWeatherview, scrollView, footerView].forEach { view.addSubview($0) }
        [maskView].forEach { scrollView.addSubview($0) }
        
        maskView.addSubview(contentView)
        maskView.clipsToBounds = true
        
        footerView.equalToBottom(toAnchor: guide.bottomAnchor)
        footerView.equalToLeading(toAnchor: guide.leadingAnchor)
        footerView.equalToTrailing(toAnchor: guide.trailingAnchor)
        footerView.equalToHeight(50.adjusted)
        
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
        scrollView.equalToTop(toAnchor: guide.topAnchor)
        scrollView.equalToLeading(toAnchor: guide.leadingAnchor)
        scrollView.equalToTrailing(toAnchor: guide.trailingAnchor)
        scrollView.equalToBottom(toAnchor: footerView.topAnchor)
        
        viewsLayouts()
    }
    
    private func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: maxH, left: 0, bottom: 0, right: 0)
        
        tableView.register(WeekSummaryTVC.self, forCellReuseIdentifier: WeekSummaryTVC.reuseIdentifer)
        tableView.register(TodayCommentTVC.self, forCellReuseIdentifier: TodayCommentTVC.reuseIdentifer)
        tableView.register(TodayDetailTVC.self, forCellReuseIdentifier: TodayDetailTVC.reuseIdentifer)
    }
}

extension MainWeatherViewController {
    private func viewsLayouts() {

        currentWeatherview.isUserInteractionEnabled = false
        currentWeatherview.equalToTop(toAnchor: guide.topAnchor)
        currentWeatherview.equalToLeading(toAnchor: guide.leadingAnchor)
        currentWeatherview.equalToTrailing(toAnchor: guide.trailingAnchor)
        if topHeight == nil {
            topHeight = currentWeatherview.heightAnchor.constraint(equalToConstant: maxH)
            topHeight.isActive = true
        }
        
        maskView.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        if maskTop == nil {
            maskTop = maskView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topHeight.constant)
            maskTop.isActive = true
        }

        contentView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        contentView.frame = CGRect(x: 0, y: 0, width: CommonSizes.screenWidth, height: maxH + 1200)
        
        
        view.layoutIfNeeded()
        
        maskView.frame = CGRect(x: 0, y: maxH, width: CommonSizes.screenWidth, height: 500)
//        maskView.equalToHeight(stackView.frame.height)
        scrollView.contentSize = CGSize(width: CommonSizes.screenWidth, height: maxH + contentView.frame.height)
        
        Log.debug("h = \(contentView.frame)")
        view.layoutIfNeeded()
    }
}

extension MainWeatherViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == CellType.week.rawValue {
            return 9
        } else if section == CellType.todayDetail.rawValue {
            return 5
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case CellType.week.rawValue:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: WeekSummaryTVC.reuseIdentifer, for: indexPath)
                    as? WeekSummaryTVC else { fatalError("Fail to cast WeekSummaryTVC") }
            cell.setData()
            return cell
        case CellType.todayComment.rawValue:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: TodayCommentTVC.reuseIdentifer, for: indexPath)
                as? TodayCommentTVC else { fatalError("Fail to cast TodayCommentTVC") }
            cell.setData()
            return cell
        case CellType.todayDetail.rawValue:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: TodayDetailTVC.reuseIdentifer, for: indexPath)
                as? TodayDetailTVC else { fatalError("Fail to cast TodayDetailTVC") }
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
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return (section == CellType.week.rawValue) ? TimeWeatherView() : nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return (section == CellType.week.rawValue) ? 130.adjusted : 0
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = scrollView.contentOffset.y
        let tempH: CGFloat = maxH - (offsetY + maxH)
        let height: CGFloat = min(max(tempH, minH), maxH * 1.5)
        
        if offsetY >= 200 {
            let yy = offsetY + 100
            maskView.frame = CGRect(x: 0, y: yy, width: CommonSizes.screenWidth, height: 500 + offsetY)
            contentView.frame = CGRect(x: 0, y: (300 - yy), width: CommonSizes.screenWidth, height: maxH + 1200)
        } else {
            maskView.frame = CGRect(x: 0, y: maxH, width: CommonSizes.screenWidth, height: 500 + offsetY)
            contentView.frame = CGRect(x: 0, y: 0, width: CommonSizes.screenWidth, height: maxH + 1200)
        }
        
        Log.debug("stack = \(contentView.frame)")
        
        DispatchQueue.main.async {
//            self.topHeight.constant = height
            
//            if offsetY < -self.maxH {
//                scrollView.contentInset = UIEdgeInsets(top: self.maxH, left: 0, bottom: 0, right: 0)
//            } else {
//                scrollView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
//            }
//
//            self.currentWeatherview.updateLayoutWhenScroll(viewHeight: height)
        }
        
        //        Log.debug("offsetY = \(offsetY)")
    }
}
