//
//  CacheStorage.swift
//  KPCore
//
//  Created by henry on 2018. 3. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public protocol CacheStorage {
    associatedtype Value
    
    init(name: String, costLimit: Int, countLimit: Int)
    
    var name: String { get set }
    var totalCostLimit: Int { get set }
    var countLimit: Int { get set }
    
    subscript(key: String) -> Value? { get set }
    func value(forKey key: String) -> Value?
    func setValue(_ maybeValue: Value?, forKey key: String, cost: Int)
    func removeValue(forKey key: String)
    func removeAll()
}

public enum CacheType {
    case memory
    case file
}
