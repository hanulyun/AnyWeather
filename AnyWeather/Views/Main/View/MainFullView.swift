//
//  MainFullView.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainFullView: CustomView {
    
    private let currentWeatherview: MainTempView = MainTempView()
    
    private let hScrollView: UIScrollView = UIScrollView()
    private let timeStackView: UIStackView = UIStackView().basicStyle(.horizontal)
    
    private let vScrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView().filledStyle(color: UIColor.purple.withAlphaComponent(0.5))
    private let contentMaskView: UIView = UIView().filledStyle(color: UIColor.cyan.withAlphaComponent(0.3))
    
    // contentView
    private let dailyStackView: UIStackView = UIStackView().basicStyle(.vertical)
    private let todaySummaryView: TodaySummaryView = TodaySummaryView()
    private let todayDetailStackView: UIStackView = UIStackView().basicStyle(.vertical)
    
    struct Layout {
        static let headerMaxH: CGFloat = MainSizes.currentMaxHeight
        static let headerMinH: CGFloat = MainSizes.currentMinHeight
        static let timeWeatherHeight: CGFloat = 130.adjusted
        static let fullHeader: CGFloat = Layout.headerMaxH + Layout.timeWeatherHeight
        static let footerHeight: CGFloat = 50.adjusted
        static var contentHeight: CGFloat = 1200
    }
    
    private var topHeight: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        
        setInit(.brown)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(model: CurrentModel) {
        currentWeatherview.setData(model: model)
        
        for _ in 0..<9 {
            let timeCell: TimeWeatherCell = TimeWeatherCell()
            timeCell.setData()
            timeStackView.addArrangedSubview(timeCell)
        }
        
        for _ in 0..<9 {
            let dailyCell: DailyWeatherCell = DailyWeatherCell()
            dailyCell.setData()
            dailyStackView.addArrangedSubview(dailyCell)
        }
        
        todaySummaryView.setData()
        
        for _ in 0..<5 {
            let detailCell: TodayDetailCell = TodayDetailCell()
            detailCell.setData()
            todayDetailStackView.addArrangedSubview(detailCell)
        }
    }
    
    override func configureAutolayouts() {
        [currentWeatherview, vScrollView, hScrollView].forEach { addSubview($0) }
        vScrollView.addSubview(contentMaskView)
        contentMaskView.addSubview(contentView)
        [dailyStackView, todaySummaryView, todayDetailStackView].forEach { contentView.addSubview($0) }
        hScrollView.addSubview(timeStackView)
        
        currentWeatherview.equalToTop(toAnchor: self.topAnchor)
        currentWeatherview.equalToLeading(toAnchor: self.leadingAnchor)
        currentWeatherview.equalToTrailing(toAnchor: self.trailingAnchor)
        if topHeight == nil {
            topHeight
                = currentWeatherview.heightAnchor.constraint(equalToConstant: Layout.headerMaxH)
            topHeight.isActive = true
        }
        
        hScrollView.equalToTop(toAnchor: currentWeatherview.bottomAnchor)
        hScrollView.equalToLeading(toAnchor: self.leadingAnchor)
        hScrollView.equalToTrailing(toAnchor: self.trailingAnchor)
        hScrollView.equalToHeight(Layout.timeWeatherHeight)
        hScrollView.equalToWidth(CommonSizes.screenWidth)
        
        timeStackView.equalToEdges(to: hScrollView)
        
        vScrollView.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
        vScrollView.equalToTop(toAnchor: self.topAnchor)
        vScrollView.equalToLeading(toAnchor: self.leadingAnchor)
        vScrollView.equalToTrailing(toAnchor: self.trailingAnchor)
        vScrollView.equalToBottom(toAnchor: self.bottomAnchor)
        
        dailyStackView.equalToTop(toAnchor: contentView.topAnchor)
        dailyStackView.equalToLeading(toAnchor: contentView.leadingAnchor)
        dailyStackView.equalToTrailing(toAnchor: contentView.trailingAnchor)
        dailyStackView.equalToWidth(CommonSizes.screenWidth)
        
        todaySummaryView.equalToTop(toAnchor: dailyStackView.bottomAnchor)
        todaySummaryView.equalToLeading(toAnchor: contentView.leadingAnchor)
        todaySummaryView.equalToTrailing(toAnchor: contentView.trailingAnchor)
        
        todayDetailStackView.equalToTop(toAnchor: todaySummaryView.bottomAnchor)
        todayDetailStackView.equalToLeading(toAnchor: contentView.leadingAnchor)
        todayDetailStackView.equalToTrailing(toAnchor: contentView.trailingAnchor)
        
        prepareViewsFrame()
    }
    
    private func prepareViewsFrame() {
        contentView.frame = CGRect(x: 0, y: 0, width: CommonSizes.screenWidth,
                                 height: Layout.contentHeight)
        contentMaskView.frame = CGRect(x: 0, y: Layout.fullHeader,
                                       width: CommonSizes.screenWidth, height: Layout.contentHeight)
        vScrollView.contentSize = CGSize(width: CommonSizes.screenWidth,
                                        height: Layout.fullHeader + contentView.frame.height)
        
        contentMaskView.clipsToBounds = true
    }
}
