//
//  FriendFileDatabase.swift
//  Kakaopay
//
//  Created by Miller on 2018. 5. 10..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

public class FileDatabaseStorage<Value>: CacheStorage {

    private let database = File.applicationSupport
    
    required public init(name: String = "default", costLimit: Int = 0, countLimit: Int = 0) {
        self.name = name
        self.totalCostLimit = costLimit
        self.countLimit = countLimit
    }
    
    public var name: String
    public var totalCostLimit: Int {
        didSet {
            // database mgmt 필요시 구현.
        }
    }
    
    public var countLimit: Int {
        didSet {
            // database mgmt 필요시 구현.
        }
    }
    
    private var currentSize: Int {
        return database.contentsSize(forDirectory: name)
    }
    
    private var currentCount: Int {
        return database.contentsCount(forDirectory: name)
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
        database.delete(at: fileName(forKey: key))
    }
    
    public func removeAll() {
        database.delete(at: name)
    }
    
}

// MARK: - Supports DataRepresentable protocol
extension FileDatabaseStorage where Value: DataRepresentable {
    
    public func value(forKey key: String) -> Value? {
        return database.read(fileName: fileName(forKey: key))
    }
    
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        // cost, count mgmt here
        database.write(value, fileName: fileName(forKey: key))
    }
}

// Codable
extension FileDatabaseStorage where Value: Codable {
    public func value(forKey key: String) -> Value? {
        return database.read(fileName: fileName(forKey: key))
    }
    
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        
        // cost, count mgmt here
        database.write(value, fileName: fileName(forKey: key))
    }
}

// Codable Array
extension FileDatabaseStorage where Value: Codable, Value: ExpressibleByArrayLiteral {
    
    public func value(forKey key: String) -> Value? {
        return database.read(fileName: fileName(forKey: key))
    }
    
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        
        // cost, count mgmt here
        database.write(value, fileName: fileName(forKey: key))
    }
}

// Codable Dictionary
extension FileDatabaseStorage where Value: Codable, Value: ExpressibleByDictionaryLiteral {
    
    public func value(forKey key: String) -> Value? {
        return database.read(fileName: fileName(forKey: key))
    }
    
    public func setValue(_ maybeValue: Value?, forKey key: String, cost: Int = 0) {
        guard let value = maybeValue else {
            removeValue(forKey: key)
            return
        }
        
        // cost, count mgmt here
        database.write(value, fileName: fileName(forKey: key))
    }
}

