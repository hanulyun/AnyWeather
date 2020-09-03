//
//  ReusableView.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/03.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

protocol ReusableView {
    static var reusableIdentifier: String { get }
}

extension UITableViewCell: ReusableView {
    static var reusableIdentifier: String {
        return String(describing: self)
    }
}
