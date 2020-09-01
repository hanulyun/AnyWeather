//
//  URL+File.swift
//  KPCore
//
//  Created by henry on 2018. 2. 1..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension URL {
    
    public enum Directory {
        case library
        case applicationSupport
        case document
        case caches
        case temp
        
        public func urlString() -> String {
            switch self {
            case .library:
                return pathsInDomain(.libraryDirectory)
            case .applicationSupport:
                return pathsInDomain(.applicationSupportDirectory)
            case .document:
                return pathsInDomain(.documentDirectory)
            case .caches:
                return pathsInDomain(.cachesDirectory)
            case .temp:
                return NSTemporaryDirectory()
            }
        }
        
        private func pathsInDomain(_ directory: FileManager.SearchPathDirectory) -> String {
            let directories = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)
            guard let path = directories.first else {
                return ""
            }
            return path
        }
    }
    
    public init(directory: Directory, relativePath: String? = nil) {
        var urlString = directory.urlString()
        if let relativePath = relativePath {
            urlString = urlString + "/" + relativePath
        }
        self.init(fileURLWithPath: urlString)
    }
    
}

