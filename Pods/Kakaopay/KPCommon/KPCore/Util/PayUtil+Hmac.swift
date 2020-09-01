//
//  PayUtil+Hmac.swift
//  KPCommon
//
//  Created by Freddy on 11/01/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import Foundation

public extension PayUtil {
    struct Hmac {
        private static let keyList = ["A3JR7sXQN7", "ssxnV14Taj", "t+x8Nf4+XJ", "pZwfcneoCG", "qxgdv+20iZ", "A22iK1iQre", "LaEGfkCwPp", "fc4K7GdmIG", "pUNWV8F1zt", "LcBUYozKLT"]
        
        public static func encode(_ message: String) -> (seed: Int, result: String)? {
            let seed = (Int)(arc4random() % UInt32(keyList.count))
            let key = Data(keyList[seed].utf8)
            
            if let result = message.pay.HmacSHA256(key: key)?.pay.base64UrlEncodedString() {
                return (seed, result)
            }
            
            return nil
        }
    }
}
