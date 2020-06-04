//
//  CGFloat+Double+Extensions.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension CGFloat {
    var adjusted: CGFloat {
        return self * (Sizes.screenWidth / 375)
    }
}

extension Double {
    var adjusted: CGFloat {
        return CGFloat(self) * (Sizes.screenWidth / 375)
    }
}
