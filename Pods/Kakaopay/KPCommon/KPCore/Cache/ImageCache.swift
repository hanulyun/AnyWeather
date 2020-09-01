//
//  ImageCache.swift
//  KPUI
//
//  Created by henry on 2018. 3. 7..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public final class ImageCache {
    
    public static let shared = ImageCache(name: "image")
    
    private let memoryCache: MemoryCacheStorage<UIImage>
    private let fileCache: FileCacheStorage<UIImage>
    
    public init(name: String) {
        memoryCache = MemoryCacheStorage<UIImage>(name: name)
        fileCache = FileCacheStorage<UIImage>(name: name)
    }
    
    public func hashedKey(_ key: String) -> String {
        return File.hashedFileName(key)
    }
    
    public subscript(key: String, type: CacheType) -> UIImage? {
        get {
            return value(forKey: hashedKey(key), type: type)
        }
        set {
            setValue(newValue, forKey: hashedKey(key), type: type)
        }
    }
    
    public func value(forKey key: String, type: CacheType = .file) -> UIImage? {
        switch type {
        case .file:
            return fileCache.value(forKey: hashedKey(key))
        case .memory:
            return memoryCache.value(forKey: hashedKey(key))
        }
    }
    
    public func setValue(_ maybeValue: UIImage?, forKey key: String, type: CacheType = .file) {
        switch type {
        case .file:
            return fileCache.setValue(maybeValue, forKey: hashedKey(key))
        case .memory:
            return memoryCache.setValue(maybeValue, forKey: hashedKey(key))
        }
    }
    
    public func clear() {
        fileCache.removeAll()
        memoryCache.removeAll()
    }
}

