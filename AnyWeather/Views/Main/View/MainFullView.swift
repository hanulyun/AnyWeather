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

class MainFullView: CustomView {
    
    private let currentWeatherview: MainTempView = MainTempView()
    
    // HeaderView
    private let hScrollView: UIScrollView = UIScrollView().basicStyle()
    private let hourlyStackView: UIStackView = UIStackView().basicStyle(.horizontal)
    
    // ContentView
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
        static var contentHeight: CGFloat = 1200
    }
    
    private var topHeight: NSLayoutConstraint!
    
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
        
        // Content Layout
        prepareViewsFrame()
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
    
    private func prepareViewsFrame() {
        self.layoutIfNeeded()
        Layout.contentHeight
            = dailyStackView.frame.height + todaySummaryView.frame.height + todayDetailStackView.frame.height
            + 20.adjusted
        Log.debug("height = \(dailyStackView.frame.height)")
        contentView.frame = CGRect(x: 0, y: 0, width: CommonSizes.screenWidth,
                                 height: Layout.contentHeight)
        contentMaskView.frame = CGRect(x: 0, y: Layout.fullHeader,
                                       width: CommonSizes.screenWidth, height: Layout.contentHeight)
        vScrollView.contentSize = CGSize(width: CommonSizes.screenWidth,
                                         height: Layout.fullHeader + Layout.contentHeight)
        
        contentMaskView.clipsToBounds = true
        
        vScrollView.setContentOffset(CGPoint(x: 0, y: scrollY), animated: false)
    }
    
    override func configureAutolayouts() {
        [currentWeatherview, vScrollView, hScrollView].forEach { addSubview($0) }
        vScrollView.addSubview(contentMaskView)
        contentMaskView.addSubview(contentView)
        [dailyStackView, todaySummaryView, todayDetailStackView].forEach { contentView.addSubview($0) }
        hScrollView.addSubview(hourlyStackView)
        
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
        
        hourlyStackView.equalToEdges(to: hScrollView)
        
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
    }
}

extension MainFullView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = scrollView.contentOffset.y
        scrollY = offsetY
        var height: CGFloat = Layout.headerMaxH - offsetY
        if Layout.headerMaxH - offsetY <= Layout.headerMinH {
            height = Layout.headerMinH
        }
        topHeight.constant = height

        if height == Layout.headerMinH {
            let headerBottomY: CGFloat = offsetY + Layout.headerMinH + Layout.timeWeatherHeight
            contentMaskView.frame = CGRect(x: 0, y: headerBottomY,
                                    width: CommonSizes.screenWidth, height: Layout.contentHeight + offsetY)
            contentView.frame = CGRect(x: 0, y: (Layout.fullHeader - headerBottomY),
                                     width: CommonSizes.screenWidth,
                                     height: Layout.contentHeight)
        } else {
            contentMaskView.frame = CGRect(x: 0, y: Layout.fullHeader,
                                    width: CommonSizes.screenWidth, height: Layout.contentHeight + offsetY)
            contentView.frame = CGRect(x: 0, y: 0,
                                     width: CommonSizes.screenWidth,
                                     height: Layout.contentHeight)
        }

        DispatchQueue.main.async {
            self.currentWeatherview.updateLayoutWhenScroll(viewHeight: self.topHeight.constant)
        }
    }
}
