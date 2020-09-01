//
//  String+Mask.swift
//  KPCommon
//
//  Created by kali_company on 24/11/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == String {
    public func masking(_ on: String.Position, offsetBy: Int, length: Int, to: String) -> String {
        return base.masking(on, offsetBy: offsetBy, length: length, to: to)
    }
}

extension String {
    public enum Position {
        case front, rear
    }
    
    internal func masking(_ on: Position, offsetBy: Int, length: Int, to: String) -> String {
        switch on {
        case .front:
            let start = index(self.startIndex, offsetBy: offsetBy)
            let end = index(start, offsetBy: length)
            return replacingCharacters(in: start..<end, with: String(repeating: to, count: length))
            
        case .rear:
            guard count > offsetBy else {
                return self
            }
            
            var avaliableLength = (count - offsetBy)
            avaliableLength = (avaliableLength - length) > 0 ? length : avaliableLength
            let start = index(endIndex, offsetBy: -offsetBy)
            let end = index(start, offsetBy: -avaliableLength)
            return replacingCharacters(in: end..<start , with: String(repeating: to, count: avaliableLength))
        }
    }
}
