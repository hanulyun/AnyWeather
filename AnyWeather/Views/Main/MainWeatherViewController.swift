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
    private let timeWeatherView: TimeWeatherView = TimeWeatherView()
    
    private let tableView: UITableView = UITableView()
    private let footerView: FooterView = FooterView()
    
    private let maskView = UIView()
    private let contentView = UIView()
    
    struct Layout {
        static let headerMaxH: CGFloat = MainSizes.currentMaxHeight
        static let headerMinH: CGFloat = MainSizes.currentMinHeight
        static let timeWeatherHeight: CGFloat = 130.adjusted
        static let fullHeader: CGFloat = Layout.headerMaxH + Layout.timeWeatherHeight
    }

    private let viewModel: MainWeatherViewModel = MainWeatherViewModel()
    
    private var topHeight: NSLayoutConstraint!
    
    enum CellType: Int {
        case week = 0
        case todayComment = 1
        case todayDetail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        
    }
    
    override func bindData() {
        footerView.setPageControl(withOutGps: 3)
        
        viewModel.requestCurrentGps { [weak self] model in
            if let model: CurrentModel = model {
                DispatchQueue.main.async {
                    self?.currentWeatherview.setData(model: model)
                }
            }
        }
    }
    
    override func configureAutolayouts() {
        [currentWeatherview, timeWeatherView, scrollView, footerView].forEach { view.addSubview($0) }
        scrollView.addSubview(maskView)
        maskView.addSubview(contentView)
        maskView.clipsToBounds = true
        
        headerFooterViewsLayouts()
        scrollViewLayouts()
    }
}

extension MainWeatherViewController {
    private func headerFooterViewsLayouts() {
        currentWeatherview.equalToTop(toAnchor: guide.topAnchor)
        currentWeatherview.equalToLeading(toAnchor: guide.leadingAnchor)
        currentWeatherview.equalToTrailing(toAnchor: guide.trailingAnchor)
        if topHeight == nil {
            topHeight = currentWeatherview.heightAnchor.constraint(equalToConstant: Layout.headerMaxH)
            topHeight.isActive = true
        }
        
        timeWeatherView.equalToTop(toAnchor: currentWeatherview.bottomAnchor)
        timeWeatherView.equalToLeading(toAnchor: guide.leadingAnchor)
        timeWeatherView.equalToTrailing(toAnchor: guide.trailingAnchor)
        timeWeatherView.equalToHeight(Layout.timeWeatherHeight)
        
        footerView.equalToBottom(toAnchor: guide.bottomAnchor)
        footerView.equalToLeading(toAnchor: guide.leadingAnchor)
        footerView.equalToTrailing(toAnchor: guide.trailingAnchor)
        footerView.equalToHeight(50.adjusted)
    }
    
    private func scrollViewLayouts() {
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
        scrollView.equalToTop(toAnchor: guide.topAnchor)
        scrollView.equalToLeading(toAnchor: guide.leadingAnchor)
        scrollView.equalToTrailing(toAnchor: guide.trailingAnchor)
        scrollView.equalToBottom(toAnchor: footerView.topAnchor)
        
        maskView.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        contentView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        
        contentView.frame = CGRect(x: 0, y: 0, width: CommonSizes.screenWidth, height: Layout.headerMaxH + 1200)
        
        view.layoutIfNeeded()
        
        maskView.frame = CGRect(x: 0, y: Layout.fullHeader, width: CommonSizes.screenWidth, height: 500)
        scrollView.contentSize = CGSize(width: CommonSizes.screenWidth, height: Layout.headerMaxH + contentView.frame.height)
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = scrollView.contentOffset.y
        var height: CGFloat = Layout.headerMaxH - offsetY
        if Layout.headerMaxH - offsetY <= Layout.headerMinH {
            height = Layout.headerMinH
        }
        topHeight.constant = height
        
        Log.debug("stack = \(height)")
        
        if height == Layout.headerMinH {
            let yy = offsetY + Layout.headerMinH + Layout.timeWeatherHeight
            maskView.frame = CGRect(x: 0, y: yy, width: CommonSizes.screenWidth, height: 500 + offsetY)
            contentView.frame = CGRect(x: 0, y: (Layout.headerMaxH - yy), width: CommonSizes.screenWidth, height: Layout.headerMaxH + 1200)
        } else {
            maskView.frame = CGRect(x: 0, y: Layout.fullHeader, width: CommonSizes.screenWidth, height: 500 + offsetY)
            contentView.frame = CGRect(x: 0, y: 0, width: CommonSizes.screenWidth, height: Layout.headerMaxH + 1200)
        }
        
        DispatchQueue.main.async {
            self.currentWeatherview.updateLayoutWhenScroll(viewHeight: self.topHeight.constant)
        }
    }
}
