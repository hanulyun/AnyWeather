//
//  Certificate.swift
//  KPCommon
//
//  Created by kali_company on 15/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

import Foundation

public final class Certificate {
    public enum Status: String {
        case none = "NONE"
        case issued = "GOOD"
        case block = "BLOCK"
        case expired = "EXPIRED"
        case revoked = "REVOKED"
    }
    
    private let certificate: PayCertificate?
    
    public init(pemCertificate: String) {
        certificate = PayCertificate(pemCertificate: pemCertificate)
    }
    
    public init(pemCertificateInfo: [String: String]) {
        certificate = PayCertificate(pemCertificateInfo: pemCertificateInfo)
    }
    
    public var pemCertificate: String? {
        return certificate?.pemCertificate ?? nil
    }
    
    public var derCertificate: Data? {
        return certificate?.derCertificate ?? nil
    }
    
    public var serial: String? {
        return certificate?.serial ?? nil
    }
    
    public var subject: String? {
        return certificate?.subject ?? nil
    }
    
    public var issuer: String? {
        return certificate?.issuer ?? nil
    }
    
    public var constraint: String? {
        return certificate?.constraint ?? nil
    }
    
    public var usage: String? {
        return certificate?.usage ?? nil
    }
    
    public var issueDate: Date? {
        return certificate?.issueDate ?? nil
    }
    
    public var expireDate: Date? {
        return certificate?.expireDate ?? nil
    }
}
