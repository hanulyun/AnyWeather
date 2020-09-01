//
//  ECKeyPair.swift
//  KPCommon
//
//  Created by kali_company on 15/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

import Foundation

public final class ECKeyPair {
    let keyPair: PayECKeyPair?
    
    public init(pemDataPrivateKey: Data) {
        keyPair = PayECKeyPair(pemDataPrivateKey: pemDataPrivateKey)
    }
    
    public init() {
        keyPair = PayECKeyPair()
    }
    
    public func pemPrivateKey(isExistLabel: Bool) -> Data? {
        guard let keyPair = keyPair else { return nil }
        
        return keyPair.pemDataPrivateKey(withKeyLabelHidden: !isExistLabel)
    }
    
    public func pemPublicKey(isExistLabel: Bool) -> Data? {
        guard let keyPair = keyPair else { return nil }
        
        return keyPair.pemDataPublicKey(withKeyLabelHidden: !isExistLabel)
    }
    
    public func derPublicKey() -> Data? {
        guard let keyPair = keyPair else { return nil }
        
        return keyPair.derPublicKey()
    }
    
    public func isValidKeyPair() -> Bool {
        return (keyPair != nil)
    }
}
