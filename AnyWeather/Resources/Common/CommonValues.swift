//
//  CommonValues.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

struct Sizes {
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
}

public enum ColorSet {
    case background
    case main
    
    public var rawValue: UIColor {
        switch self {
        case .background: return .lightGray
        case .main: return .white
        }
    }
}

public enum FontSet {
    case mainBig
    case mainMiddle
    case subMiddle
    case subSmall
    
    public var rawValue: UIFont {
        switch self {
        case .mainBig: return .systemFont(ofSize: 60.adjusted, weight: .regular)
        case .mainMiddle: return .systemFont(ofSize: 30.adjusted, weight: .regular)
        case .subMiddle: return .systemFont(ofSize: 20.adjusted, weight: .regular)
        case .subSmall: return .systemFont(ofSize: 15.adjusted, weight: .regular)
        }
    }
}
