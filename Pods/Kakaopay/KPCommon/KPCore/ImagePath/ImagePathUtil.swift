//
//  AppIntegrity.swift
//  KPCore
//
//  Created by kali_company on 2018. 5. 28..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

/*
 앱위변조 공격 비용 증가를 enum, function 이름을 임의로 변경 하였습니다.
*/
public final class ImagePathUtil {
    public static func commonPath() -> Bool {
        return NSImagePathUtil.commonPath()
    }
    
    public static func relativePath() -> Bool {
        return NSImagePathUtil.relativePath()
    }
    
    public static func shutterSpeed() -> Void {
        return NSImagePathUtil.shutterSpeed()
    }
    
    public static func serialize(path: String, options: ImagePathOptions) -> (Bool, ImagePathError?) {
        var resultCode: Int = -1
        let isValid = NSImagePathUtil.serialize(path, options: options.rawValue, result: &resultCode)
        return (isValid, ImagePathError(rawValue: resultCode))
    }
}

// lib_defines.h 참고
@objc public enum ImagePathOptions: UInt8 {
    case OPT_IMAGE_VALIDATE_CODE_NONE = 0
    
    // Code Block이 암호화 되어 있으면, 앱스토어 설치 파일이므로 무결성 검사하지 않음
    // 성능은 향상되나 쉽게 우회됨
    case OPT_IMAGE_VALIDATE_CODE_PASS = 0x1
    
    // Code Block이 암호화 되어 있지 않으면, 앱스토어 설치 파일이 아니므로 무결하지 않은 파일로 처리
    // Swift 동적 라이브러리와 같은 dylib 는 암호화 되어 있지 않으므로 이 옵션은 MH_EXECUTE 이 아니면 자동 비활성화 됨
    case OPT_IMAGE_VALIDATE_CODE_INVALID = 0x2
    
    // Code Block이 반드시 암호화 되어야 한다면, 퍼알터압과 상관없이 암호화되지 코드는 무결하지 않은 파일로 처리
    // 경고) OPT_IMAGE_VALIDATE_CODE_INVALID은 무시되며 framework, dylib 파일 암호화 상태를 AppStore 버전에서 사전 체크해야 함
    case OPT_IMAGE_VALIDATE_CODE_FORCEINVALID = 0x4
    
    // preset for dist phase
    public static var product = ImagePathOptions.OPT_IMAGE_VALIDATE_CODE_INVALID // AppStore, Product 모드
    public static var sandbox = ImagePathOptions.OPT_IMAGE_VALIDATE_CODE_NONE // Dev, Sandbox 모드
}

@objc public enum ImagePathError: Int {
    case RET_IMAGE_FAIL = -1             // invalid macho format
    case RET_IMAGE_VALID = 0             // valid code hash
    case RET_IMAGE_INVALID = 1           // invalid code hash
    case RET_IMAGE_INVALID_CD = 2        // invalid code directory
//    case RET_IMAGE_INVALID_TID = 3       // invalid team id
    
    public var code: String {
        switch self {
        case .RET_IMAGE_FAIL: return "RET_IMAGE_FAIL"
        case .RET_IMAGE_VALID: return "RET_IMAGE_VALID"
        case .RET_IMAGE_INVALID: return "RET_IMAGE_INVALID"
        case .RET_IMAGE_INVALID_CD: return "RET_IMAGE_INVALID_CD"
//        case .RET_IMAGE_INVALID_TID: return "RET_IMAGE_INVALID_TID"
        default: return "RET_UNKNOWN"
        }
    }
    
    public var reason: String {
        switch self {
        case .RET_IMAGE_FAIL: return "[!] somthing wrong fail..."
        case .RET_IMAGE_VALID: return "[-] valid hash. file ok!"
        case .RET_IMAGE_INVALID: fallthrough
        case .RET_IMAGE_INVALID_CD: fallthrough
//        case .RET_IMAGE_INVALID_TID: return "[-] invalid hash. file modified!"
        default: return "[?] unknown reason"
        }
    }
}
