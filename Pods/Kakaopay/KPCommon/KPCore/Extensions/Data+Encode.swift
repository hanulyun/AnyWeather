//
//  Data+Encode.swift
//  KPCore
//
//  Created by kali_company on 2018. 3. 23..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == Data {
    public static func base64UrlEncoded(string: String) -> Data? {
        return Data(base64UrlEncoded: string)
    }
    
    public func base64UrlEncodedString() -> String {
        return base.base64UrlEncodedString()
    }
    
    public func base64UrlEncodedStringWithPadding() -> String {
        return base.base64UrlEncodedStringWithPadding()
    }
    
    public func SHA256() -> Data? {
        return base.SHA256()
    }
    
    public func HmacSHA256(key: Data) -> Data? {
        return base.HmacSHA256(key: key)
    }
    
    public func AES256Encrypt(key: Data) -> Data? {
        return base.AES256Encrypt(key: key)
    }
    
    public func AES256Decrypt(key: Data) -> Data? {
        return base.AES256Decrypt(key: key)
    }
}

extension Data {
    internal init?(base64UrlEncoded string: String) {
        let base64Encoded = string
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
        if base64Encoded.count % 4 != 0 {
            let padLength = (4 - (base64Encoded.count % 4))
            let base64EncodedWithPadding = base64Encoded + String(repeating: "=", count: padLength)
            self.init(base64Encoded: base64EncodedWithPadding)
        } else {
            self.init(base64Encoded: base64Encoded)
        }
    }
    
    internal func base64UrlEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }
    
    internal func base64UrlEncodedStringWithPadding() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
    }
    
    internal func SHA256() -> Data? {
        return Crypto.SHA256(self)
    }
    
    internal func HmacSHA256(key: Data) -> Data? {
        return Crypto.HmacSHA256(self, key: key)
    }
    
    internal func AES256Encrypt(key: Data) -> Data? {
        return Crypto.AES256Encrypt(self, key: key)
    }
    
    internal func AES256Decrypt(key: Data) -> Data? {
        return Crypto.AES256Decrypt(self, key: key)
    }
    
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
