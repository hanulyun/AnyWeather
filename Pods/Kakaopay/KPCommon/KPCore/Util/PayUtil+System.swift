//
//  PayUtil+System.swift
//  KPCommon
//
//  Created by Freddy on 11/01/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import AdSupport

public extension PayUtil {
    struct System {
        public static var appVersion: String {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        }
        
        public static var buildVersion: String {
            return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
        }
        
        public static var osVersion: String {
            return UIDevice.current.systemVersion
        }
        
        public static var language: String {
            let lang = Locale.preferredLanguages.first
            return lang?.components(separatedBy: "-").first ?? "ko"
        }
        
        // KakaoTalk에서 사용하는 방식으로.. (using Alamofire)
        // Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
        public static var acceptLanguage: String {
            return Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
                let quality = 1.0 - (Double(index) * 0.1)
                return "\(languageCode);q=\(quality)"
                }.joined(separator: ", ")
        }
        
        public static var deviceModel: String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            return machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        }
        
        public static var adid: String {
            let adid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            return adid
        }
        
        public static var adidTrackingEnabled: Bool {
            let trackingEnabled = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
            return trackingEnabled
        }
    }
}
