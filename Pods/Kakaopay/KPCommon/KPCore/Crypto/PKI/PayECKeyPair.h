//
//  PayECKeyPair.h
//  KPCommon
//
//  Created by kali_company on 15/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayECKeyPair : NSObject

@property (nonatomic, strong) NSData* privateKeyData;
@property (nonatomic, strong) NSString* base64URLEncodedPrivateKey;
@property (nonatomic, strong) NSString* base64URLEncodedPublicKeyPointX;
@property (nonatomic, strong) NSString* base64URLEncodedPublicKeyPointY;
//- (NSString*)base64EncodedDERSignatureWithData:(id)inputData;
//- (NSString*)base64EncodedSignatureWithDataString:(NSString*)dataString;

- (nullable instancetype)initWithPEMDataPrivateKey:(NSData*)PEMDataPrivateKey;

- (NSData*)PEMDataPrivateKeyWithKeyLabelHidden:(BOOL)hidden;
- (NSData*)PEMDataPublicKeyWithKeyLabelHidden:(BOOL)hidden;
- (NSData*)DERPublicKey;

@end

NS_ASSUME_NONNULL_END

