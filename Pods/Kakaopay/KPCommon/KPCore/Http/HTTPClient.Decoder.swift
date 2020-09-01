//
//  HTTPClientDecoder.swift
//  KPCore
//
//  Created by henry on 2018. 4. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension HTTPClient {
    
    public class Decoder: JSONDecoder {    
        override public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
            if T.self == Data.self {
                return data as! T
            } else if T.self == String.self {
                return (String(bytes: data, encoding: .utf8) ?? "") as! T
            }
            
            return try super.decode(T.self, from: data)
        }
    }
}
