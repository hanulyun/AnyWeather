//
//  Crypto.swift
//  KPCommon
//
//  Created by kali_company on 2018. 3. 21..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation
import Security


extension String {
    func exportToUnsafeMutablePointer() -> UnsafeMutablePointer<UInt8>? {
        var cstring = self.utf8CString
        let pointer = cstring.withUnsafeMutableBytes { (bufferPointer: UnsafeMutableRawBufferPointer) in
            bufferPointer.baseAddress?.bindMemory(to: UInt8.self, capacity: bufferPointer.count)
        }
        return pointer
    }
}
extension Data {
    func exportToUnsafeMutablePointer() -> UnsafeMutablePointer<UInt8>? {
        
        let data = self
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        pointer.initialize(repeating: 0, count: data.count)
        for i in 0 ..< data.count {
            pointer[i] = data[i]
        }
        return pointer
        
    }
}

public final class Crypto: NSObject {
    @objc public static func ARIAEncript(key: String, iv: Data, plain: String) -> Data? {

        guard let plainData = plain.data(using: .utf8, allowLossyConversion: true) else {
            return nil
        }
        
        let ptrKey = key.exportToUnsafeMutablePointer()
        let ptrPlain = plainData.exportToUnsafeMutablePointer()
        let ptrIv = iv.exportToUnsafeMutablePointer()
        
        var ptrChiper = UnsafeMutablePointer<UInt8>.allocate(capacity: plainData.count+16)
        ptrChiper.initialize(repeating: 0, count: plainData.count+16)
        defer {
            ptrChiper.deallocate()
            ptrIv?.deallocate()
        }
        
        let nOutLength = KISA_ARIA256_CBC_ENCRYPT(ptrKey, ptrIv, ptrPlain, UInt32(plainData.count), ptrChiper)
        let resultData = Data(bytes: ptrChiper, count: Int(nOutLength))
        return resultData
    }
    
    @objc public static func ARIADecrypt(key: String, iv: Data, data: Data) -> Data? {
        let ptrKey = key.exportToUnsafeMutablePointer()
        let ptrIv = iv.exportToUnsafeMutablePointer()
        let ptrData = data.exportToUnsafeMutablePointer()
        
        let ptrPlain = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        ptrPlain.initialize(repeating: 0, count: data.count)
        defer {
            ptrPlain.deallocate()
            ptrIv?.deallocate()
            ptrData?.deallocate()
        }
        
        let nOutLength = KISA_ARIA256_CBC_DECRYPT(ptrKey, ptrIv, ptrData, UInt32(data.count), ptrPlain)
        if nOutLength == 0 { return nil }
        let decryptedData = Data(bytes: ptrPlain, count: Int(nOutLength))
        return decryptedData
    }
    
    @objc public static func makeRandomIV() -> Data? {
        var keyData = Data(count: 16)
        let result = keyData.withUnsafeMutableBytes { bytes -> Int32 in
            guard let baseAddress = bytes.baseAddress else { return -1 }
            return SecRandomCopyBytes(kSecRandomDefault, 16, baseAddress)
        }
        if result == errSecSuccess {
            return keyData
        }
        return nil
    }
       
    
    @objc public static func SHA256(_ original: Data) -> Data? {
        guard original.count > 0 else {
            return nil
        }
        
        return PayCrypto.sha256(original)
    }

    @objc public static func HmacSHA256(_ original: Data, key: Data) -> Data? {
        guard original.count > 0 else {
            return nil
        }
        
        return PayCrypto.hmacSHA256(original, key:key)
    }
    
    @objc public static func AES256Encrypt(_ plain: Data, key: Data, iv: Data? = nil) -> Data? {
        guard plain.count > 0 else {
            return nil
        }
        
        if let `iv` = iv {
            return PayCrypto.aes256Encrypt(plain, iv: iv, key: key)
        } else {
            return PayCrypto.aes256Encrypt(plain, key:key)
        }
    }
    
    @objc public static func AES256Decrypt(_ cryptex: Data, key: Data, iv: Data? = nil) -> Data? {
        guard cryptex.count > 0 else {
            return nil
        }
        
        if let `iv` = iv {
            return PayCrypto.aes256Decrypt(cryptex, iv: iv, key: key)
        } else {
            return PayCrypto.aes256Decrypt(cryptex, key:key)
        }
    }
    
    @objc public static func PBKDFKey(from data: Data, salt: Data) -> Data? {
        guard data.count > 0 && salt.count > 0 else {
            return nil
        }
        
        return PayCrypto.pbkdfKey(from:data, salt:salt)
    }
    
    @objc public static func createRSAKeyPair(publicTag: String, privateTag: String, accessGroup: String? = nil) -> Bool {
        deleteKeyPairInKeyChain(publicTag)
        deleteKeyPairInKeyChain(privateTag)
        
        guard let `publicTag` = publicTag.data(using: .utf8), let `privateTag` = privateTag.data(using: .utf8) else { return false }
        
        let publicKeyAttr: [String: Any] = [kSecAttrApplicationTag as String: publicTag]
        let privateKeyAttr: [String: Any] = [kSecAttrApplicationTag as String: privateTag,
                                             kSecAttrIsPermanent as String: true]
        
        var keyPariAttr: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA as String,
                                          kSecAttrKeySizeInBits as String: 2048,
                                          kSecPublicKeyAttrs as String: publicKeyAttr,
                                          kSecPrivateKeyAttrs as String: privateKeyAttr,
                                          kSecAttrIsPermanent as String: true]
        
        if let accessGroup = accessGroup {
            keyPariAttr[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var error: Unmanaged<CFError>?
        if let _ = SecKeyCreateRandomKey(keyPariAttr as CFDictionary, &error) {
            return true
        } else {
            return false
        }
    }
    
    @objc public static func RSAEncrypt(_ plain: Data, tag: String, accessGroup: String? = nil) -> Data? {
        guard plain.count > 0 && !tag.isEmpty else {
            return nil
        }
        
        guard let publicKey = Crypto.retrieveRSAKey(tag, accessGroup: accessGroup) else { return nil }
        
        let algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            return nil
        }

        let srclen = plain.count;
        let blockSize = SecKeyGetBlockSize(publicKey) * (Int8.bitWidth / 8)
        let srcBlockSize = blockSize - 11
        let count = (srclen / srcBlockSize) + ((srclen % srcBlockSize) == 0 ? 0 : 1)
        
        var ret = Data()
        for index in 0..<count {
            let dataPos = index * srcBlockSize
            
            var data = Data()
            if plain.count < dataPos + srcBlockSize {
                data = plain.subdata(in: dataPos..<plain.count)
            } else {
                data = plain.subdata(in: dataPos..<(dataPos + srcBlockSize))
            }
            
            var error: Unmanaged<CFError>?
            guard let cipher = SecKeyCreateEncryptedData(publicKey,
                                                             algorithm,
                                                             data as CFData,
                                                             &error) as Data? else {
                                                               return nil
            }
            
            ret.append(cipher)
        }
        
        return ret
    }
    
    @objc public static func RSADecrypt(_ cipher: Data, tag: String, accessGroup: String? = nil) -> Data? {
        guard cipher.count > 0 && !tag.isEmpty else {
            return nil
        }
        
        guard let privateKey = Crypto.retrieveRSAKey(tag, accessGroup: accessGroup) else { return nil }
        
        let algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
            return nil
        }
        
        let srclen = cipher.count;
        let blockSize = SecKeyGetBlockSize(privateKey) * (Int8.bitWidth / 8)
        let count = (srclen / blockSize)
        
        var ret = Data()
        
        for index in 0..<count {
            let dataPos = index * blockSize
            
            var data = Data()
            data = cipher.subdata(in: dataPos..<(dataPos + blockSize))
            
            var error: Unmanaged<CFError>?
            guard let plain = SecKeyCreateDecryptedData(privateKey,
                                                         algorithm,
                                                         data as CFData,
                                                         &error) as Data? else {
                                                            return nil
            }
            
            ret.append(plain)
        }
        
        return ret
    }
    
    public static func retrieveRSAKey(_ tag: String, accessGroup: String? = nil) -> SecKey? {
        guard let `tag` = tag.data(using: .utf8) else { return nil }
        
        var query: [String: Any] = [kSecClass as String: kSecClassKey as String,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                    kSecReturnRef as String: true]
      
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var key: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &key)
        guard status == errSecSuccess else { return nil }
        let result = key as! SecKey
        return result
    }
    
    @discardableResult private static func deleteKeyPairInKeyChain(_ tag: String) -> Bool {
        guard let `tag` = tag.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [kSecClass as String: kSecClassKey as String,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecAttrKeyType as String: kSecAttrKeyTypeRSA as String]
        return (SecItemDelete(query as CFDictionary) ==  errSecSuccess)
    }
    
    public static func DERSignature(with ecKeyPair: ECKeyPair, data: Data, isNoneHash: Bool = false) -> Data? {
        guard let keyPair = ecKeyPair.keyPair else { return nil }
        return PayCrypto.derSignature(with: keyPair, data: data, isNoneHash: isNoneHash)
    }
    
    public static func signaute(with ecKeyPair: ECKeyPair, dataString: String) -> Data? {
        guard let keyPair = ecKeyPair.keyPair else { return nil }
        return PayCrypto.signature(with: keyPair, dataString: dataString)
    }
    
    // 기존 인증서비스에서 잘못된 코드를 대응하기 위해 부득이하게 ㅠㅠ
    public static func base64UrlDecodeForPKI(_ base64UrlEncoded: String) -> Data {
        return PayCrypto.base64UrlDecodeForPKI(fromEncodedString: base64UrlEncoded)
    }
}
