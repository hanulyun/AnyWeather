//
//  String+Encode.swift
//  KPCore
//
//  Created by kali_company on 2018. 3. 23..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base == String {
    public static func base64Encoded(string: String) -> String? {
        return String(base64Encoded: string)
    }
    
    public func base64EncodedString() -> String {
        return base.base64EncodedString()
    }
    
    public static func base64URLEncoded(string: String) -> String? {
        return String(base64URLEncoded: string)
    }
    
    public func base64UrlEncodedString() -> String {
        return base.base64UrlEncodedString()
    }
    
    public func urlEncodedString() -> String? {
        return base.urlEncodedString()
    }
    
    public func urlDecodedString() -> String? {
        return base.urlDecodedString()
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

extension String {
    internal init?(base64Encoded string: String) {
        guard let data = Data(base64Encoded: string) else {
            return nil
        }
        
        self.init(data: data, encoding: .utf8)
    }
    
    internal func base64EncodedString() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    internal init?(base64URLEncoded string: String) {
        guard let data = Data(base64UrlEncoded: string) else {
            return nil
        }
        
        self.init(data: data, encoding: .utf8)
    }
    
    internal func base64UrlEncodedString() -> String {
        return Data(self.utf8).base64UrlEncodedString()
    }
    
    internal func urlEncodedString() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    internal func urlDecodedString() -> String? {
        return self.removingPercentEncoding
    }
    
    internal func SHA256() -> Data? {
        guard self.count > 0, let original = self.data(using: .utf8) else {
            return nil
        }
        
        return original.SHA256()
    }
    
    internal func HmacSHA256(key: Data) -> Data? {
        guard self.count > 0, let original = self.data(using: .utf8) else {
            return nil
        }
        
        return original.HmacSHA256(key: key)
    }
    
    internal func AES256Encrypt(key: Data) -> Data? {
        guard self.count > 0, let plain = self.data(using: .utf8) else {
            return nil
        }
        
        return plain.AES256Encrypt(key: key)
    }
    
    internal func AES256Decrypt(key: Data) -> Data? {
        guard self.count > 0, let cryptex = self.data(using: .utf8) else {
            return nil
        }
        
        return cryptex.AES256Decrypt(key: key)
    }
}
