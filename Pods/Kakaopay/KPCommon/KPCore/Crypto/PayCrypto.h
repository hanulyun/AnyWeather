//
//  PayCryptor.h
//  KPCore
//
//  Created by kali_company on 2018. 3. 21..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PayECKeyPair;
@interface PayCrypto : NSObject

+ (nonnull NSData *)SHA256:(nonnull NSData*)data;
+ (nonnull NSData *)HmacSHA256:(nonnull NSData*)data key:(nonnull NSData*)key;
+ (nullable NSData *)AES256Encrypt:(nonnull NSData *)plain key:(nonnull NSData *)key;
+ (nullable NSData *)AES256Encrypt:(nonnull NSData *)plain iv:(nonnull NSData *)iv key:(nonnull NSData *)key;
+ (nullable NSData *)AES256Decrypt:(nonnull NSData *)cryptex key:(nonnull NSData *)key;
+ (nullable NSData *)AES256Decrypt:(nonnull NSData *)cryptex iv:(nonnull NSData *)iv key:(nonnull NSData *)key;

+ (nullable NSData *)PBKDFKeyFromData:(nonnull NSData*)data salt:(nonnull NSData *)salt;

+ (nullable NSData *)DERSignatureWithEcKeyPair:(nonnull PayECKeyPair *)ecKeyPair data:(nonnull NSData *)inputData isNoneHash:(BOOL)isNoneHash;
+ (nullable NSData *)signatureWithEcKeyPair:(nonnull PayECKeyPair *)ecKeyPair dataString:(nonnull NSString *)dataString;

+ (nonnull NSData *)base64UrlDecodeForPKIFromEncodedString:(nonnull NSString *)encodedString;

@end
