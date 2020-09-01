//
//  Collection+Extensions.swift
//  KPCore
//
//  Created by Freddy on 2018. 7. 5..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Collection {
    public subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
