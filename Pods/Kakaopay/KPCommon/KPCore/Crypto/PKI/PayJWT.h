//
//  PayJWT.h
//  KPCommon
//
//  Created by kali_company on 16/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PayECKeyPair.h"

NS_ASSUME_NONNULL_BEGIN

@interface PayJWT : NSObject

//+ (NSString *)base64URLEncodedDERSignatureWithEcKeyPair:(PayECKeyPair *)ecKeyPair data:(NSData *)inputData;
//+ (NSString *)base64URLEncodedSignatureWithEcKeyPair:(PayECKeyPair *)ecKeyPair dataString:(NSString *)dataString;

//+ (BOOL)verifyJWT:(NSString*)jwt withEcKey:(EC_KEY*)ecKey;
+ (NSDictionary<NSString *, id> *)payloadFromJWT:(NSString *)jwt withPEMCertificate:(NSString *)PEMCetificate;

@end

NS_ASSUME_NONNULL_END
