//
//  MemoryCacheStorage.swift
//  KPCore
//
//  Created by henry on 2018. 3. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

/*
 implementation via NSCache
 https://developer.apple.com/documentation/foundation/nscache
 */
public class MemoryCacheStorage<Value>: CacheStorage {
    
    private let cache = NSCache<NSString, AnyObject>()
    
    required public init(name: String = "default", costLimit: Int = 0, countLimit: Int = 0) {
        self.name = name
        self.totalCostLimit = costLimit
        self.countLimit = countLimit
    }
    
    public var name: String {
        get {
            return cache.name
        }
        set {
            cache.name = newValue
        }
    }
    
    public var totalCostLimit: Int {
        get {
            return cache.totalCostLimit
        }
        set {
            cache.totalCostLimit = newValue
        }
    }
    
    public var countLimit: Int {
        get {
            return cache.countLimit
        }
        set {
            cache.countLimit = newValue
        }
    }
    
    public subscript(key: String) -> Value? {
        get {
            return value(forKey: key)
        }
        set {
            setValue(newValue, forKey: key)
        }
    }

    public func value(forKey key: String) -> Value? {
        return cache.object(forKey: key as NSString) as? Value
    }
    
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {}
    
    public func removeValue(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    public func removeAll() {
        cache.removeAllObjects()
    }
}

// MARK: - Supports AnyObject
extension MemoryCacheStorage where Value: AnyObject {

    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        cache.setObject(value, forKey: key as NSString, cost: cost)
    }
}

// MARK: - Supports Swift (converting obj-c primitive value to swift primitive value)
extension MemoryCacheStorage where Value: StringProtocol {

    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        cache.setObject((value as! NSString), forKey: key as NSString, cost: cost)
    }
}

extension MemoryCacheStorage where Value: ExpressibleByDictionaryLiteral {
    
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        cache.setObject((value as! NSDictionary), forKey: key as NSString, cost: cost)
    }
}

extension MemoryCacheStorage where Value: ExpressibleByArrayLiteral {

    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        cache.setObject((value as! NSArray), forKey: key as NSString, cost: cost)
    }
}

