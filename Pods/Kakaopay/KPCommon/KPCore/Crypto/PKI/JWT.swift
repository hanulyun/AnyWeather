//
//  JWT.swift
//  KPCommon
//
//  Created by kali_company on 16/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

import Foundation

public final class JWT {
    public static func payload(from jwt:String, pemCertificate:String) -> [String:Any] {
        return PayJWT.payload(fromJWT: jwt, withPEMCertificate: pemCertificate)
    }
    
    public static func signature(ecKeyPair: ECKeyPair, header: String, payload: String) -> String? {
        let headerAndPayload = String(format: "%@.%@", header, payload)
        if let signature = Crypto.signaute(with: ecKeyPair, dataString: headerAndPayload) {
            return signature.base64UrlEncodedString()
        } else {
            return nil
        }
    }
}
