//
//  MainWeatherFullView.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainWeatherFullView: ModuleView, MainNamespace {
    
    @IBOutlet weak var nowWeatherView: UIView!
    @IBOutlet weak var hourlyHStackView: UIStackView!
    
    @IBOutlet weak var contentVScrollView: UIScrollView!
    @IBOutlet weak var contentMaskView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dailyStackView: UIStackView!
    @IBOutlet weak var todaySummaryLabel: UILabel!
    @IBOutlet weak var todayDetailStackView: UIStackView!
    
    @IBOutlet weak var nowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var maskTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
    
    private lazy var _nowWeatherView = MainNowWeatherView.instantiate()
    
    override class func instantiate() -> Self {
        let view = loadFromNib(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: CommonSizes.screenWidth).isActive = true
        return view
    }
    
    func initializeUI(model: Model.Weather) {
        
        contentVScrollView.delegate = self
        
        initializeNowWeatherView(model: model)
        initializeHourlyWeatherView(model: model)
        initializeDailyWeatherView(model: model)
        initializeTodaySummaryWeatherView(model: model)
        initializeDetailWeatherView(model: model)
    }
    
    private func initializeNowWeatherView(model: Model.Weather) {
        nowWeatherView.addSubview(_nowWeatherView)
        _nowWeatherView.initializeUI(model: model, viewHeight: nowHeightConstraint.constant)
    }
    
    private func initializeHourlyWeatherView(model: Model.Weather) {
        hourlyHStackView.removeAllSubviews()
        if let hourModels = model.hourly, hourModels.count >= 24 {
            for index in 0..<24 {
                let hourlyView = MainHourlyWeatherView.instantiate()
                hourlyView.initializeUI(model: hourModels[index], isFirst: (index == 0))
                hourlyHStackView.addArrangedSubview(hourlyView)
            }
        }
    }
    
    private func initializeDailyWeatherView(model: Model.Weather) {
        dailyStackView.removeAllSubviews()
        if let dailyModels = model.daily, dailyModels.count >= 8 {
            for index in 0..<7 {
                let dailyView = MainDailyWeatherView.instantiate()
                dailyView.initializeUI(model: model.daily?[index + 1])
                dailyStackView.addArrangedSubview(dailyView)
            }
        }
    }
    
    private func initializeTodaySummaryWeatherView(model: Model.Weather) {
        var comment: String = "오늘: "
        if let desc: String = model.current?.weather?.first?.description {
            comment.append(desc)
        }
        if let max: Double = model.daily?.first?.temp?.max {
            let maxInt: Int = Int(max)
            comment.append(", 최고 기온은 \(maxInt.description)\(Main.degSymbol)입니다.")
        }
        if let min: Double = model.daily?.first?.temp?.min {
            let minInt: Int = Int(min)
            comment.append(" 최저 기온은 \(minInt.description)\(Main.degSymbol)입니다.")
        }
        todaySummaryLabel.text = comment
    }
    
    private func initializeDetailWeatherView(model: Model.Weather) {
        todayDetailStackView.removeAllSubviews()
        let detailModels: [Model.Detail] = arrangeDetailItems(model: model.current)
        for (index, detail) in detailModels.enumerated() {
            let detailView = MainDetailWeatherView.instantiate()
            detailView.initializeUI(model: detail, isLast: (index == (detailModels.count - 1)))
            todayDetailStackView.addArrangedSubview(detailView)
        }
    }
    
    private func arrangeDetailItems(model: Model.Weather.Current?) -> [Model.Detail] {
        let sunrise: String? = model?.sunrise?.timestampToString(format: "a h:mm")
        let sunset: String? = model?.sunset?.timestampToString(format: "a h:mm")
        let windDeg: String?
            = "\(model?.wind_deg?.calcWindDirection() ?? "") \(Int(model?.wind_speed ?? 0).description )m/s"
        let humi: String? = "\(Int(model?.humidity ?? 0).description)%"
        let feels: String? = "\(Int(model?.feels_like ?? 0).description)\(Main.degSymbol)"
        let press: String? = "\(Int(model?.pressure ?? 0).description)hPa"
        let visi: String? = "\(((model?.visibility ?? 0) / 1000).description)km"
        let uvi: String? = Int(model?.uvi ?? 0).description
        let details: [Model.Detail] = [
            Model.Detail(leftTitle: "일출", leftValue: sunrise, rightTitle: "읿몰", rightValue: sunset),
            Model.Detail(leftTitle: "바람", leftValue: windDeg, rightTitle: "습도", rightValue: humi),
            Model.Detail(leftTitle: "체감", leftValue: feels, rightTitle: "기압", rightValue: press),
            Model.Detail(leftTitle: "가시거리", leftValue: visi, rightTitle: "자외선 지수", rightValue: uvi)
        ]
        return details
    }
}

extension MainWeatherFullView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY: CGFloat = scrollView.contentOffset.y
        let scrollUpOffsetY: CGFloat = Model.Sizes.headerMaxH - offSetY
        
        if scrollUpOffsetY <= Model.Sizes.headerMinH {
            nowHeightConstraint.constant = Model.Sizes.headerMinH
            maskTopConstraint.constant = Model.Sizes.headerMinH + Model.Sizes.hourlyWeatherH
            contentTopConstraint.constant = (Model.Sizes.headerMaxH - Model.Sizes.headerMinH) - offSetY
        } else {
            nowHeightConstraint.constant = scrollUpOffsetY
            maskTopConstraint.constant = Model.Sizes.fullHeaderH - offSetY
            contentTopConstraint.constant = 0
        }
        
        _nowWeatherView.updateLayoutWhenScrolling(viewHeight: nowHeightConstraint.constant)
    }
}
