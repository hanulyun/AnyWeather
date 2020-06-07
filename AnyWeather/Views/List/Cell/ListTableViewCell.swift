//
//  ListTableViewCell.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    static let reuseId: String = "ListTableViewCell"
    
    private let containerView: UIView = UIView()
    
    private let timeLabel: UILabel = UILabel()
    private let gpsImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "gps_highlighted"))
        return imageView
    }()
    private let cityLabel: UILabel = UILabel()
    private let tempLabel: UILabel = UILabel()
    
    private var topConst: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        configureAutolayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(model: WeatherModel, isFirst: Bool) {
        backgroundColor = .getWeatherColor(model.current?.weather?.first?.id)
        
        let now: Date = Date()
        timeLabel.text = now.dateToString(format: "a h:m")
        timeLabel.setFont(.font(.subTiny), color: .color(.main))
        
        cityLabel.text = model.city
        cityLabel.setFont(.font(.mainMiddle), color: .color(.main))
        
        let temp: Int = Int(model.current?.temp ?? 0)
        tempLabel.text = "\(String(temp))\(degSymbol)"
        tempLabel.setFont(.font(.mainBig), color: .color(.main))
        
        gpsImageView.isHidden = !isFirst
    }
}

extension ListTableViewCell {
    private func configureAutolayouts() {
        addSubview(containerView)
        [timeLabel, gpsImageView, cityLabel, tempLabel].forEach { containerView.addSubview($0) }
        
        containerView.equalToEdges(to: self)
        
        let parentView: UIView = containerView
        if topConst == nil {
            topConst = timeLabel.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 16.adjusted)
            topConst.isActive = true
        }
        timeLabel.equalToLeading(toAnchor: parentView.leadingAnchor, offset: 16.adjusted)
        
        gpsImageView.equalToCenterY(yAnchor: timeLabel.centerYAnchor)
        gpsImageView.equalToLeading(toAnchor: timeLabel.trailingAnchor, offset: 4.adjusted)
        gpsImageView.equalToSize(10.adjusted)
        
        cityLabel.equalToTop(toAnchor: timeLabel.bottomAnchor, offset: 8.adjusted)
        cityLabel.equalToLeading(toAnchor: timeLabel.leadingAnchor)
        cityLabel.equalToBottom(toAnchor: parentView.bottomAnchor, offset: -16.adjusted)
        
        tempLabel.equalToCenterY(yAnchor: parentView.centerYAnchor)
        tempLabel.equalToTrailing(toAnchor: parentView.trailingAnchor, offset: -16.adjusted)
    }
}
