//
//  PayOpenSSLHelper.h
//  KPCommon
//
//  Created by kali_company on 15/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/ecdsa.h>
#import <openssl/ossl_typ.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayOpenSSLHelper : NSObject

+ (EC_KEY*)ecKeyWithPEMCertificate:(NSString *)PEMCertificate;
+ (NSString *)removeKeyLabelFrom:(NSString *)key;
+ (nullable NSData *)dataFromBN:(const BIGNUM *)bn;

NS_ASSUME_NONNULL_END

@end
