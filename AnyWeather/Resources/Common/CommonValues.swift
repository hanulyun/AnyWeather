//
//  CommonValues.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

public let degSymbol: String = "°"

struct CommonSizes {
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
}

struct MainSizes {
    static let currentMaxHeight: CGFloat = 310
    static let currentMinHeight: CGFloat = 100
}

public enum ObserverKey: String {
    case contentSize = "contentSize"
}

public enum ColorSet {
    case background
    case main
    case translucentMain
    
    public var rawValue: UIColor {
        switch self {
        case .background: return .lightGray
        case .main: return .white
        case .translucentMain: return UIColor.white.withAlphaComponent(0.5)
        }
    }
}

public enum FontSet {
    case mainBig
    case mainMiddle
    case subBig
    case subMiddle
    case subSmall
    case subTiny
    
    public var rawValue: UIFont {
        switch self {
        case .mainBig: return .systemFont(ofSize: 65.adjusted, weight: .light)
        case .mainMiddle: return .systemFont(ofSize: 30.adjusted)
        case .subBig: return .systemFont(ofSize: 26.adjusted)
        case .subMiddle: return .systemFont(ofSize: 20.adjusted)
        case .subSmall: return .systemFont(ofSize: 15.adjusted)
        case .subTiny: return .systemFont(ofSize: 12.adjusted)
        }
    }
}

public enum Direction: String {
    case n
}
