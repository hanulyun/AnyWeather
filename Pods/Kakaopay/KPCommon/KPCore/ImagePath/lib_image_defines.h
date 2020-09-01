//
//  return_code.h
//  imagePathlib
//
//  Created by ariesike on 08/11/2019.
//  Copyright © 2019 주성범. All rights reserved.
//

#ifndef lib_image_defines_h
#define lib_image_defines_h

/*
 앱위변조 공격 비용 증가를 enum 이름을 임의로 변경 하였습니다.
*/

//
// Input Option Values
//
enum {
    // Code Block이 암호화 되어 있으면, 앱스토어 설치 파일이므로 무결성 검사하지 않음
    // 성능은 향상되나 쉽게 우회됨
//    OPT_ENCRYPTED_CODE_PASS         = 0x1,
    OPT_IMAGE_VALIDATE_CODE_PASS         = 0x1,
    
    // Code Block이 암호화 되어 있지 않으면, 앱스토어 설치 파일이 아니므로 무결하지 않은 파일로 처리
    // Swift 동적 라이브러리와 같은 dylib 는 암호화 되어 있지 않으므로 이 옵션은 MH_EXECUTE 이 아니면 자동 비활성화 됨
//    OPT_DECRYPTED_CODE_INVALID      = 0x2,
    OPT_IMAGE_VALIDATE_CODE_INVALID      = 0x2,

    // Code Block이 반드시 암호화 되어야 한다면, 퍼알터압과 상관없이 암호화되지 코드는 무결하지 않은 파일로 처리
    // 경고) OPT_IMAGE_VALIDATE_CODE_INVALID은 무시되며 framework, dylib 파일 암호화 상태를 AppStore 버전에서 사전 체크해야 함
//    OPT_DECRYPTED_CODE_FORCEINVALID = 0x4,
    OPT_IMAGE_VALIDATE_CODE_FORCEINVALID = 0x4,
    
    // Embedded Entitlements, CMS Data 내에 Team ID 체크 비활성화. MH_EXECUTE 파일이 아니면 자동으로 활성화 됨
    // 경고) [Deprecated] 기본 활성화로 더이상 사용되지 않음
//    OPT_TEAMID_CHECK_DISABLE        = 0x8,
    OPT_IMAGE_META_DISABLE        = 0x8,
    
    //
    // Defaults Options
//    OPT_PRODUCT_DEFAULT = OPT_DECRYPTED_CODE_INVALID,  // AppStore, Product 모드
    OPT_PRODUCT_DEFAULT = OPT_IMAGE_VALIDATE_CODE_INVALID,  // AppStore, Product 모드
    OPT_SANDBOX_DEFAULT = 0  // Dev, Sandbox 모드
};


//
// Return codes
//
enum {
    RET_IMAGE_FAIL        = -1,  // invalid macho format
    RET_IMAGE_VALID       = 0,   // valid code hash
    RET_IMAGE_INVALID     = 1,   // invalid code hash
    RET_IMAGE_INVALID_CD  = 2,   // invalid code directory
//    RET_IMAGE_INVALID_TID = 3,   // [Deprecated] invalid team id
};

#endif /* lib_image_defines_h */
