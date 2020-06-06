//
//  ViewController.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainWeatherViewController: BaseViewController {
    
    private let hScrollView: UIScrollView = UIScrollView()
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let currentWeatherview: MainTempView = MainTempView()
    private let timeWeatherView: TimeWeatherView = TimeWeatherView()
    
    private let tableView: UITableView = UITableView()
    private let maskView: UIView = UIView().filledStyle(color: UIColor.blue.withAlphaComponent(0.5))
    
    private let footerView: FooterView = FooterView()
        
    struct Layout {
        static let headerMaxH: CGFloat = MainSizes.currentMaxHeight
        static let headerMinH: CGFloat = MainSizes.currentMinHeight
        static let timeWeatherHeight: CGFloat = 130.adjusted
        static let fullHeader: CGFloat = Layout.headerMaxH + Layout.timeWeatherHeight
        static let footerHeight: CGFloat = 50.adjusted
        static var contentHeight: CGFloat = 100
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
                
        prepareTableView()
        
        buttonEvent()
    }
    
    deinit {
        Log.debug("call")
        tableView.removeObserver(self, forKeyPath: ObserverKey.contentSize.rawValue)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == ObserverKey.contentSize.rawValue {
            if let newSize: CGSize = change?[.newKey] as? CGSize {
                Layout.contentHeight = newSize.height
                self.prepareViewsFrame()
            }
        }
    }
    
    private func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        
        tableView.register(WeekSummaryTVC.self, forCellReuseIdentifier: WeekSummaryTVC.reuseIdentifer)
        tableView.register(TodayCommentTVC.self, forCellReuseIdentifier: TodayCommentTVC.reuseIdentifer)
        tableView.register(TodayDetailTVC.self, forCellReuseIdentifier: TodayDetailTVC.reuseIdentifer)
        
        tableView.addObserver(self, forKeyPath: ObserverKey.contentSize.rawValue,
                              options: .new, context: nil)
        prepareViewsFrame()
    }
    
    private func buttonEvent() {
        footerView.listButton.addTarget(self, action: #selector(listButtonTap), for: .touchUpInside)
    }
    
    @objc func listButtonTap() {
        Log.debug("tap!")
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
        [currentWeatherview, scrollView, timeWeatherView, footerView].forEach { view.addSubview($0) }
        scrollView.addSubview(maskView)
        maskView.addSubview(tableView)
        maskView.clipsToBounds = true
        
        headerFooterViewsLayouts()
        scrollViewLayouts()
    }
}

// MARK: - Autolayout
extension MainWeatherViewController {
    private func headerFooterViewsLayouts() {
        currentWeatherview.equalToTop(toAnchor: guide.topAnchor)
        currentWeatherview.equalToLeading(toAnchor: guide.leadingAnchor)
        currentWeatherview.equalToTrailing(toAnchor: guide.trailingAnchor)
        if topHeight == nil {
            topHeight
                = currentWeatherview.heightAnchor.constraint(equalToConstant: Layout.headerMaxH)
            topHeight.isActive = true
        }
        
        timeWeatherView.equalToTop(toAnchor: currentWeatherview.bottomAnchor)
        timeWeatherView.equalToLeading(toAnchor: guide.leadingAnchor)
        timeWeatherView.equalToTrailing(toAnchor: guide.trailingAnchor)
        timeWeatherView.equalToHeight(Layout.timeWeatherHeight)
        
        footerView.equalToBottom(toAnchor: guide.bottomAnchor)
        footerView.equalToLeading(toAnchor: guide.leadingAnchor)
        footerView.equalToTrailing(toAnchor: guide.trailingAnchor)
        footerView.equalToHeight(Layout.footerHeight)
    }
    
    private func scrollViewLayouts() {
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
        scrollView.equalToTop(toAnchor: guide.topAnchor)
        scrollView.equalToLeading(toAnchor: guide.leadingAnchor)
        scrollView.equalToTrailing(toAnchor: guide.trailingAnchor)
        scrollView.equalToBottom(toAnchor: footerView.topAnchor)
    }
    
    private func prepareViewsFrame() {
        tableView.frame = CGRect(x: 0, y: 0, width: CommonSizes.screenWidth,
                                 height: Layout.contentHeight)
        maskView.frame = CGRect(x: 0, y: Layout.fullHeader,
                                width: CommonSizes.screenWidth, height: 500)
        scrollView.contentSize = CGSize(width: CommonSizes.screenWidth,
                                        height: Layout.fullHeader + tableView.frame.height)
    }
}

// MARK: - TableView
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = scrollView.contentOffset.y
        var height: CGFloat = Layout.headerMaxH - offsetY
        if Layout.headerMaxH - offsetY <= Layout.headerMinH {
            height = Layout.headerMinH
        }
        topHeight.constant = height
                
        if height == Layout.headerMinH {
            let headerBottomY: CGFloat = offsetY + Layout.headerMinH + Layout.timeWeatherHeight
            maskView.frame = CGRect(x: 0, y: headerBottomY,
                                    width: CommonSizes.screenWidth, height: 500 + offsetY)
            tableView.frame = CGRect(x: 0, y: (Layout.fullHeader - headerBottomY),
                                     width: CommonSizes.screenWidth,
                                     height: Layout.contentHeight)
        } else {
            maskView.frame = CGRect(x: 0, y: Layout.fullHeader,
                                    width: CommonSizes.screenWidth, height: 500 + offsetY)
            tableView.frame = CGRect(x: 0, y: 0,
                                     width: CommonSizes.screenWidth,
                                     height: Layout.contentHeight)
        }
        
        DispatchQueue.main.async {
            self.currentWeatherview.updateLayoutWhenScroll(viewHeight: self.topHeight.constant)
        }
    }
}
