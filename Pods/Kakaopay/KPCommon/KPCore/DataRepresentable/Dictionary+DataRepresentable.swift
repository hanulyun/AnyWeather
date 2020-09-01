//
//  Dictionary+DataRepresentable.swift
//  KPCore
//
//  Created by henry on 2018. 3. 30..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension Dictionary: DataRepresentable where Key == String, Value == Any {

    public func toData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    public static func fromData<ReturnType>(_ data: Data) -> ReturnType? {
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? ReturnType
    }
}

