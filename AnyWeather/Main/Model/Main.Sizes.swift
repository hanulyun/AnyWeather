//
//  Main.Sizes.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/02.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension Main.Model {
    struct Sizes {
        static let headerMaxH: CGFloat = 310
        static let headerMinH: CGFloat = 100
        static let hourlyWeatherH: CGFloat = 130
        static let fullHeaderH: CGFloat = Sizes.headerMaxH + Sizes.hourlyWeatherH
        static let footerHeight: CGFloat = 50
    }
}
