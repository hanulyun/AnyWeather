//
//  PayUtil+Device.swift
//  KPCommon
//
//  Created by Freddy on 11/01/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import LocalAuthentication

public extension PayUtil {
    struct Device {
        public static var isLocked: Bool {
            let context = LAContext()
            return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        }
        
        public static var current: AppleDevice {
            return AppleDevice.device(identifier: PayUtil.System.deviceModel)
        }
    }
}

extension PayUtil.Device {
    //https://www.theiphonewiki.com/wiki/Models
    public enum AppleDevice: Equatable {
        case iPodTouch6
        case iPhone4
        case iPhone4s
        case iPhone5
        case iPhone5c
        case iPhone5s
        case iPhoneSE
        case iPhone6
        case iPhone6Plus
        case iPhone6s
        case iPhone6sPlus
        case iPhone7
        case iPhone7Plus
        case iPhone8
        case iPhone8Plus
        case iPhoneX
        case iPhoneXR
        case iPhoneXS
        case iPhoneXSMax
        case iPhone11
        case iPhone11Pro
        case iPhone11ProMax
        case iPad2
        case iPad3
        case iPad4
        case iPadAir
        case iPadAir2
        case iPadMini
        case iPadMini2
        case iPadMini3
        case iPadMini4
        case iPadPro
        case appleTV
        case simulator
        case undefined(identifier: String)
        
        public static func device(identifier: String) -> AppleDevice {
            switch identifier {
            case "iPod7,1": return .iPodTouch6
            case "iPhone3,1", "iPhone3,2", "iPhone3,3": return .iPhone4
            case "iPhone4,1": return .iPhone4s
            case "iPhone5,1", "iPhone5,2": return .iPhone5
            case "iPhone5,3", "iPhone5,4": return .iPhone5c
            case "iPhone6,1", "iPhone6,2": return .iPhone5s
            case "iPhone8,4": return .iPhoneSE
            case "iPhone7,2": return .iPhone6
            case "iPhone7,1": return .iPhone6Plus
            case "iPhone8,1": return .iPhone6s
            case "iPhone8,2": return .iPhone6sPlus
            case "iPhone9,1", "iPhone9,3": return .iPhone7
            case "iPhone9,2", "iPhone9,4": return .iPhone7Plus
            case "iPhone10,1", "iPhone10,4": return .iPhone8
            case "iPhone10,2", "iPhone10,5": return .iPhone8Plus
            case "iPhone10,3", "iPhone10,6": return .iPhoneX
            case "iPhone11,8": return .iPhoneXR
            case "iPhone11,2": return .iPhoneXS
            case "iPhone11,6", "iPhone11,4": return .iPhoneXSMax
            case "iPhone12,1": return .iPhone11
            case "iPhone12,3": return .iPhone11Pro
            case "iPhone12,5": return .iPhone11ProMax
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return .iPad2
            case "iPad3,1", "iPad3,2", "iPad3,3": return .iPad3
            case "iPad3,4", "iPad3,5", "iPad3,6": return .iPad4
            case "iPad4,1", "iPad4,2", "iPad4,3": return .iPadAir
            case "iPad5,3", "iPad5,4": return .iPadAir2
            case "iPad2,5", "iPad2,6", "iPad2,7": return .iPadMini
            case "iPad4,4", "iPad4,5", "iPad4,6": return .iPadMini2
            case "iPad4,7", "iPad4,8", "iPad4,9": return .iPadMini3
            case "iPad5,1", "iPad5,2": return .iPadMini4
            case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return .iPadPro
            case "AppleTV5,3": return .appleTV
            case "i386", "x86_64": return .simulator
            default: return .undefined(identifier: identifier) }
        }
        
        public var name: String {
            switch self {
            case .iPodTouch6: return "iPod Touch 6"
            case .iPhone4: return "iPhone 4"
            case .iPhone4s: return "iPhone 4s"
            case .iPhone5: return "iPhone 5"
            case .iPhone5c: return "iPhone 5c"
            case .iPhone5s: return "iPhone 5s"
            case .iPhoneSE: return "iPhone SE"
            case .iPhone6: return "iPhone 6"
            case .iPhone6Plus: return "iPhone 6 Plus"
            case .iPhone6s: return "iPhone 6s"
            case .iPhone6sPlus: return "iPhone 6s Plus"
            case .iPhone7: return "iPhone 7"
            case .iPhone7Plus: return "iPhone 7 Plus"
            case .iPhone8: return "iPhone 8"
            case .iPhone8Plus: return "iPhone 8 Plus"
            case .iPhoneX: return "iPhone X"
            case .iPhoneXR: return "iPhone XR"
            case .iPhoneXS: return "iPhone XS"
            case .iPhoneXSMax: return "iPhone XS Max"
            case .iPhone11: return "iPhone 11"
            case .iPhone11Pro: return "iPhone 11 Pro"
            case .iPhone11ProMax: return "iPhone 11 Pro Max"
            case .iPad2: return "iPad 2"
            case .iPad3: return "iPad 3"
            case .iPad4: return "iPad 4"
            case .iPadAir: return "iPad Air"
            case .iPadAir2: return "iPad Air 2"
            case .iPadMini: return "iPad Mini"
            case .iPadMini2: return "iPad Mini 2"
            case .iPadMini3: return "iPad Mini 3"
            case .iPadMini4: return "iPad Mini 4"
            case .iPadPro: return "iPad Pro"
            case .appleTV: return "Apple TV"
            case .simulator: return "Simulator"
            case .undefined(identifier: let identifier): return identifier
            }
        }
        
        static var iPads: [AppleDevice] {
            return [.iPad2, .iPad3, .iPad4, .iPadAir, .iPadAir2, .iPadMini, .iPadMini2, .iPadMini3, .iPadMini4, .iPadPro]
        }
        
        static var iPhones: [AppleDevice] {
            return [.iPhone4, .iPhone4s, .iPhone5, .iPhone5c, .iPhone5s, .iPhoneSE, .iPhone6, .iPhone6s, .iPhone6Plus, .iPhone7, .iPhone7Plus, .iPhone8, .iPhone8Plus, .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhoneXSMax, .iPhone11, .iPhone11Pro, .iPhone11ProMax]
        }
        
        static var lowResolutionDevices: [AppleDevice] {
            return [.iPodTouch6, .iPhone4, .iPhone4s, .iPhone5, .iPhone5c, .iPhone5s, .iPhoneSE]
        }
        
        public var isPad: Bool {
            return AppleDevice.iPads.contains { $0 == self }
        }
        
        public var isPhone: Bool {
            return AppleDevice.iPhones.contains { $0 == self }
        }
        
        public var isLowResolutionDevice: Bool {
            return AppleDevice.lowResolutionDevices.contains { $0 == self }
        }
    }
}
