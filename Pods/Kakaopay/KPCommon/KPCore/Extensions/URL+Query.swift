//
//  URL+Query.swift
//  KPCore
//
//  Created by Freddy on 2018. 5. 18..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == URL {
    public var queryParameters: [String: String]? {
        return base.queryParameters
    }
}

extension URL {
    
    /// SwifterSwift: Dictionary of the URL's query parameters
    internal var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else { return nil }
        
        var items: [String: String] = [:]
        
        for queryItem in queryItems {
            items[queryItem.name] = queryItem.value
        }
        
        return items
    }
    
    /// SwifterSwift: Get value of a query key.
    ///
    ///    var url = URL(string: "https://google.com?code=12345")!
    ///    queryValue(for: "code") -> "12345"
    ///
    /// - Parameter key: The key of a query value.
    public func queryValue(for key: String) -> String? {
        let stringURL = self.absoluteString
        guard let items = URLComponents(string: stringURL)?.queryItems else { return nil }
        for item in items where item.name == key {
            return item.value
        }
        return nil
    }
}
