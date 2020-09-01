//
//  FileCacheStorage.swift
//  KPCore
//
//  Created by henry on 2018. 3. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

/*
 implementation via File (FileManager)
 TODO: need LRU cache purge
 */
public class FileCacheStorage<Value>: CacheStorage {
    
    private let cache = File.caches
    
    required public init(name: String = "default", costLimit: Int = 0, countLimit: Int = 0) {
        self.name = name
        self.totalCostLimit = costLimit
        self.countLimit = countLimit
    }
    
    public var name: String
    public var totalCostLimit: Int {
        didSet {
            // cache mgmt 필요시 구현.
        }
    }
    
    public var countLimit: Int {
        didSet {
            // cache mgmt 필요시 구현.
        }
    }
    
    private var currentSize: Int {
        return cache.contentsSize(forDirectory: name)
    }
    
    private var currentCount: Int {
        return cache.contentsCount(forDirectory: name)
    }
    
    private func fileName(forKey key: String) -> String {
        return "\(name)/\(key)"
    }
    
    public subscript(key: String) -> Value? {
        get {
            return value(forKey: key)
        }
        set {
            setValue(newValue, forKey: key)
        }
    }
    
    public func value(forKey key: String) -> Value? { return nil }
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {}
    
    public func removeValue(forKey key: String) {
        cache.delete(at: fileName(forKey: key))
    }
    
    public func removeAll() {
        cache.delete(at: name)
    }
    
}

// MARK: - Supports DataRepresentable protocol
extension FileCacheStorage where Value: DataRepresentable {

    public func value(forKey key: String) -> Value? {
        return cache.read(fileName: fileName(forKey: key))
    }
    
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        // cost, count mgmt here
        cache.write(value, fileName: fileName(forKey: key))
    }
}

// Codable
extension FileCacheStorage where Value: Codable {
    public func value(forKey key: String) -> Value? {
        return cache.read(fileName: fileName(forKey: key))
    }
    
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        
        // cost, count mgmt here
        cache.write(value, fileName: fileName(forKey: key))
    }
}

// Codable Array
extension FileCacheStorage where Value: Codable, Value: ExpressibleByArrayLiteral {
    
    public func value(forKey key: String) -> Value? {
        return cache.read(fileName: fileName(forKey: key))
    }
    
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        
        // cost, count mgmt here
        cache.write(value, fileName: fileName(forKey: key))
    }
}

// Codable Dictionary
extension FileCacheStorage where Value: Codable, Value: ExpressibleByDictionaryLiteral {
    
    public func value(forKey key: String) -> Value? {
        return cache.read(fileName: fileName(forKey: key))
    }
    
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        
        // cost, count mgmt here
        cache.write(value, fileName: fileName(forKey: key))
    }
}
