//
//  MainFullView.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

struct DetailModel {
    var title1: String
    var value1: String?
    var title2: String
    var value2: String?
}

class MainFullView: CustomTempView {
    
    // HeaderViews
    private let currentWeatherview: MainTempView = MainTempView()
    
    private let hScrollView: UIScrollView = UIScrollView().basicStyle()
    private let hourlyStackView: UIStackView = UIStackView().basicStyle(.horizontal)
    
    // ContentViews
    private let vScrollView: UIScrollView = UIScrollView().basicStyle()
    private let contentView: UIView = UIView()
    private let contentMaskView: UIView = UIView()
    
    private let dailyStackView: UIStackView = UIStackView().basicStyle(.vertical)
    private let todaySummaryView: TodaySummaryView = TodaySummaryView()
    private let todayDetailStackView: UIStackView = UIStackView().basicStyle(.vertical)
    
    struct Layout {
        static let headerMaxH: CGFloat = MainSizes.currentMaxHeight
        static let headerMinH: CGFloat = MainSizes.currentMinHeight
        static let timeWeatherHeight: CGFloat = 130.adjusted
        static let fullHeader: CGFloat = Layout.headerMaxH + Layout.timeWeatherHeight
        static let footerHeight: CGFloat = 50.adjusted
    }
    
    private var headerHeight: NSLayoutConstraint!
    private var maskTop: NSLayoutConstraint!
    private var contentTop: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        
        setInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(model: WeatherModel) {
        // HeaderView
        currentWeatherview.setData(model: model)
        setHourly(model: model)
        
        // ContentView
        vScrollView.delegate = self
        setDaily(model: model)
        todaySummaryView.setData(model: model)
        setTodayDetail(model: model.current)
        
        contentMaskView.clipsToBounds = true
    }
    
    private func setHourly(model: WeatherModel) {
        hourlyStackView.removeAllSubviews()
        if let hourModels = model.hourly, hourModels.count >= 24 {
            for index in 0..<24 {
                let hourlyCell: HourlyWeatherCell = HourlyWeatherCell()
                hourlyCell.setData(model: hourModels[index], isFirst: index == 0)
                hourlyStackView.addArrangedSubview(hourlyCell)
            }
        }
    }
    
    private func setDaily(model: WeatherModel) {
        dailyStackView.removeAllSubviews()
        if let dailyModels = model.daily, dailyModels.count >= 8 {
            for index in 0..<7 {
                let dailyCell: DailyWeatherCell = DailyWeatherCell()
                dailyCell.setData(model: model.daily?[index + 1])
                dailyStackView.addArrangedSubview(dailyCell)
            }
        }
    }
    
    private func setTodayDetail(model: WeatherModel.Current?) {
        let sunrise: String? = model?.sunrise?.timestampToString(format: "a h:mm")
        let sunset: String? = model?.sunset?.timestampToString(format: "a h:mm")
        let windDeg: String?
            = "\(model?.wind_deg?.calcWindDirection() ?? "") \(Int(model?.wind_speed ?? 0).description )m/s"
        let humi: String? = "\(Int(model?.humidity ?? 0).description)%"
        let feels: String? = "\(Int(model?.feels_like ?? 0).description)\(degSymbol)"
        let press: String? = "\(Int(model?.pressure ?? 0).description)hPa"
        let visi: String? = "\(((model?.visibility ?? 0) / 1000).description)km"
        let uvi: String? = Int(model?.uvi ?? 0).description
        let details: [DetailModel] = [
            DetailModel(title1: "일출", value1: sunrise, title2: "일몰", value2: sunset),
            DetailModel(title1: "바람", value1: windDeg, title2: "습도", value2: humi),
            DetailModel(title1: "체감", value1: feels, title2: "기압", value2: press),
            DetailModel(title1: "가시거리", value1: visi, title2: "자외선 지수", value2: uvi)
        ]
        
        todayDetailStackView.removeAllSubviews()
        for index in details.indices {
            let detailCell: TodayDetailCell = TodayDetailCell()
            detailCell.setData(model: details[index], isLast: index == (details.count - 1))
            todayDetailStackView.addArrangedSubview(detailCell)
        }
    }
    
    override func configureAutolayouts() {
        [currentWeatherview, vScrollView, hScrollView].forEach { addSubview($0) }
        
        hScrollView.addSubview(hourlyStackView)
        
        vScrollView.addSubview(contentMaskView)
        contentMaskView.addSubview(contentView)
        [dailyStackView, todaySummaryView, todayDetailStackView].forEach { contentView.addSubview($0) }
        
        vScrollView.equalToTop(toAnchor: self.topAnchor)
        vScrollView.equalToLeading(toAnchor: self.leadingAnchor)
        vScrollView.equalToTrailing(toAnchor: self.trailingAnchor)
        vScrollView.equalToBottom(toAnchor: self.bottomAnchor)
        vScrollView.equalToWidth(CommonSizes.screenWidth)
        
        // HeaderViews
        headerViewsLayouts()
        
        // ContentViews
        contentViewLayouts()
    }
    
    private func headerViewsLayouts() {
        currentWeatherview.equalToTop(toAnchor: self.topAnchor)
        currentWeatherview.equalToLeading(toAnchor: self.leadingAnchor)
        currentWeatherview.equalToTrailing(toAnchor: self.trailingAnchor)
        if headerHeight == nil {
            headerHeight
                = currentWeatherview.heightAnchor.constraint(equalToConstant: Layout.headerMaxH)
            headerHeight.isActive = true
        }
        
        hScrollView.equalToTop(toAnchor: currentWeatherview.bottomAnchor)
        hScrollView.equalToLeading(toAnchor: self.leadingAnchor)
        hScrollView.equalToTrailing(toAnchor: self.trailingAnchor)
        hScrollView.equalToHeight(Layout.timeWeatherHeight)
        hScrollView.equalToWidth(CommonSizes.screenWidth)
        
        hourlyStackView.equalToEdges(to: hScrollView)
    }
    
    private func contentViewLayouts() {
        contentMaskView.equalToLeading(toAnchor: vScrollView.leadingAnchor)
        contentMaskView.equalToTrailing(toAnchor: vScrollView.trailingAnchor)
        contentMaskView.equalToBottom(toAnchor: vScrollView.bottomAnchor)
        if maskTop == nil {
            maskTop = contentMaskView.topAnchor.constraint(equalTo: self.topAnchor, constant: Layout.fullHeader)
            maskTop.isActive = true
        }
        
        contentView.equalToLeading(toAnchor: contentMaskView.leadingAnchor)
        contentView.equalToTrailing(toAnchor: contentMaskView.trailingAnchor)
        contentView.equalToBottom(toAnchor: contentMaskView.bottomAnchor)
        if contentTop == nil {
            contentTop = contentView.topAnchor.constraint(equalTo: contentMaskView.topAnchor, constant: 0)
            contentTop.isActive = true
        }
        
        dailyStackView.equalToTop(toAnchor: contentView.topAnchor)
        dailyStackView.equalToLeading(toAnchor: contentView.leadingAnchor)
        dailyStackView.equalToTrailing(toAnchor: contentView.trailingAnchor)
        dailyStackView.equalToWidth(CommonSizes.screenWidth)
        
        todaySummaryView.equalToTop(toAnchor: dailyStackView.bottomAnchor)
        todaySummaryView.equalToLeading(toAnchor: contentView.leadingAnchor)
        todaySummaryView.equalToTrailing(toAnchor: contentView.trailingAnchor)
        todaySummaryView.equalToWidth(CommonSizes.screenWidth)
        
        todayDetailStackView.equalToTop(toAnchor: todaySummaryView.bottomAnchor)
        todayDetailStackView.equalToLeading(toAnchor: contentView.leadingAnchor)
        todayDetailStackView.equalToTrailing(toAnchor: contentView.trailingAnchor)
        todayDetailStackView.equalToWidth(CommonSizes.screenWidth)
        todayDetailStackView.equalToBottom(toAnchor: contentView.bottomAnchor)
    }
}

extension MainFullView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = scrollView.contentOffset.y
        let scrollUpOffsetY: CGFloat = Layout.headerMaxH - offsetY
        
        if scrollUpOffsetY <= Layout.headerMinH {
            self.headerHeight.constant = Layout.headerMinH
            self.maskTop.constant = Layout.headerMinH + Layout.timeWeatherHeight
            self.contentTop.constant = (Layout.headerMaxH - Layout.headerMinH) - offsetY
        } else {
            self.headerHeight.constant = scrollUpOffsetY
            self.maskTop.constant = Layout.fullHeader - offsetY
            self.contentTop.constant = 0
        }
        
        self.currentWeatherview.updateLayoutWhenScroll(viewHeight: self.headerHeight.constant)
    }
}
