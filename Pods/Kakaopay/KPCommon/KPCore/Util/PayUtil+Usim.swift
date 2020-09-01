//
//  PayUtil+Usim.swift
//  KPCommon
//
//  Created by Freddy on 11/01/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import CoreTelephony

public extension PayUtil {
    struct Usim {
        private static var carrier: CTCarrier? {
            let networkInfo = CTTelephonyNetworkInfo()
            if #available(iOS 12.0, *) {
                // 12.0버전에서 nil로 떨어짐 버그로 추정...
                let carreier = networkInfo.serviceSubscriberCellularProviders?.values
                return carreier?.filter { !($0.mobileCountryCode?.isEmpty ?? true || $0.mobileNetworkCode?.isEmpty ?? true) }.first ?? carreier?.first ?? CTTelephonyNetworkInfo().subscriberCellularProvider
            } else {
                return networkInfo.subscriberCellularProvider
            }
        }
        
        public static var mcc: String {
            #if targetEnvironment(simulator)
            return "450"
            #else
            return carrier?.mobileCountryCode ?? ""
            #endif
        }
        
        public static var mnc: String {
            #if targetEnvironment(simulator)
            return "03"
            #else
            return carrier?.mobileNetworkCode ?? ""
            #endif
        }
        
        public static var mccmnc: String {
            return mcc + mnc
        }
        
        public static var carrierName: String {
            return carrier?.carrierName ?? ""
        }
        
        public static var isoCode: String {
            return carrier?.isoCountryCode ?? ""
        }
    }
}
