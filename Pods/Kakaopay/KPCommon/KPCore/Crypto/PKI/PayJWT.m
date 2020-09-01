//
//  PayJWT.m
//  KPCommon
//
//  Created by kali_company on 16/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

#import "PayJWT.h"

#import <openssl/obj_mac.h>
#import <openssl/objects.h>
#import <openssl/sha.h>
#import <openssl/bn.h>
#import <openssl/ecdsa.h>

#import "PayECKeyPair.h"
#import "PayOpenSSLHelper.h"
#import "PayCertUtil.h"

@interface PayECKeyPair ()
- (EC_KEY *)ecKey;
@end

@implementation PayJWT

//+ (NSString *)base64URLEncodedDERSignatureWithEcKeyPair:(PayECKeyPair *)ecKeyPair data:(NSData *)inputData
//{
//    EC_KEY *ecKey = EC_KEY_dup(ecKeyPair.ecKey);
//
//    if (!ecKey) {
//        //DebugLog(@"ECKey is NULL");
//        return nil;
//    }
//
//    const unsigned char* data = [inputData bytes];
//    size_t length = [inputData length];
//
//    NSString* base64EncodedSignature = nil;
//    unsigned char hash[SHA256_DIGEST_LENGTH] = {0,};
//
//    SHA256_CTX sha256Ctx;
//    SHA256_Init(&sha256Ctx);
//    SHA256_Update(&sha256Ctx, data, length);
//    SHA256_Final(hash, &sha256Ctx);
//
//    //NSData* hashData = [NSData dataWithBytes:hash length:SHA256_DIGEST_LENGTH];
//    //DebugLog(@"hashData >> %@", hashData);
//
//    ECDSA_SIG* signature = ECDSA_do_sign(hash, sizeof(hash), ecKey);
//    if (!signature) {
//        //error
//        //DebugLog(@"ECDSA_do_sign Error");
//        return nil;
//    }
//
//    int verify_status = ECDSA_do_verify(hash, sizeof(hash), signature, ecKey);
//    if (!verify_status) {
//        //error
//        //DebugLog(@"ECDSA_do_verify Error");
//        return nil;
//    }
//
//    uint8_t oneByteValue = 0;
//
//    NSMutableData* signatureData = [NSMutableData data];
//    NSMutableData* tempSignatureData = [NSMutableData data];
//
//    BIGNUM *r = NULL;
//    BIGNUM *s = NULL;
//
//    ECDSA_SIG_get0(signature, (const BIGNUM **)&r, (const BIGNUM **)&s);
//
//    NSData* rData = [PayOpenSSLHelper dataFromBN:r];
//    if (rData) {
//        oneByteValue = 0x02;
//        [tempSignatureData appendBytes:&oneByteValue length:1];
//
//        //first bit check
//        unsigned char* rBytes = (unsigned char*)[rData bytes];
//        if (rBytes[0] > 0x7f) {
//            oneByteValue = [rData length] + 1;
//            [tempSignatureData appendBytes:&oneByteValue length:1];
//            oneByteValue = 0x00;
//            [tempSignatureData appendBytes:&oneByteValue length:1];
//        }
//        else {
//            oneByteValue = [rData length];
//            [tempSignatureData appendBytes:&oneByteValue length:1];
//        }
//
//        [tempSignatureData appendData:rData];
//    }
//    NSData* sData = [PayOpenSSLHelper dataFromBN:s];
//    if (sData) {
//        oneByteValue = 0x02;
//        [tempSignatureData appendBytes:&oneByteValue length:1];
//
//        //first bit check
//        unsigned char* sBytes = (unsigned char*)[sData bytes];
//        if (sBytes[0] > 0x7f) {
//            oneByteValue = [sData length] + 1;
//            [tempSignatureData appendBytes:&oneByteValue length:1];
//            oneByteValue = 0x00;
//            [tempSignatureData appendBytes:&oneByteValue length:1];
//        }
//        else {
//            oneByteValue = [sData length];
//            [tempSignatureData appendBytes:&oneByteValue length:1];
//        }
//        [tempSignatureData appendData:sData];
//    }
//
//    oneByteValue = 0x30;
//    [signatureData appendBytes:&oneByteValue length:1];
//    if ([tempSignatureData length] > 0x7f) {
//        oneByteValue = 0x00;
//        [signatureData appendBytes:&oneByteValue length:1];
//    }
//    oneByteValue = [tempSignatureData length];
//    [signatureData appendBytes:&oneByteValue length:1];
//    [signatureData appendData:tempSignatureData];
//
//    if ([signatureData length] <= 0) {
//        //DebugLog(@"ECDSA_SIGN Data Error");
//        return nil;
//    }
//
//    //DebugLog(@"signatureData >> %@", signatureData);
//
//    base64EncodedSignature = [PayCertUtil base64UrlEncode:signatureData];
//    //DebugLog(@"%@", base64EncodedSignature);
//
//    return base64EncodedSignature;
//}
//
//+ (NSString*)base64URLEncodedSignatureWithEcKeyPair:(PayECKeyPair*)ecKeyPair dataString:(NSString*)dataString
//{
//    EC_KEY* ecKey = EC_KEY_dup(ecKeyPair.ecKey);
//
//    if (!ecKey) {
//        //DebugLog(@"ECKey is NULL");
//        return nil;
//    }
//
//    const unsigned char* data = (const unsigned char *)[dataString cStringUsingEncoding:NSUTF8StringEncoding];
//    size_t length = [dataString length];
//
//    NSString* base64EncodedSignature = nil;
//    unsigned char hash[SHA256_DIGEST_LENGTH] = {0,};
//
//    SHA256_CTX sha256Ctx;
//    SHA256_Init(&sha256Ctx);
//    SHA256_Update(&sha256Ctx, data, length);
//    SHA256_Final(hash, &sha256Ctx);
//
//    //NSData* hashData = [NSData dataWithBytes:hash length:SHA256_DIGEST_LENGTH];
//    //DebugLog(@"hashData >> %@", hashData);
//
//    ECDSA_SIG* signature = ECDSA_do_sign(hash, sizeof(hash), ecKey);
//    if (!signature) {
//        //error
//        //DebugLog(@"ECDSA_do_sign Error");
//        return nil;
//    }
//
//    int verify_status = ECDSA_do_verify(hash, sizeof(hash), signature, ecKey);
//    if (!verify_status) {
//        //error
//        //DebugLog(@"ECDSA_do_verify Error");
//        return nil;
//    }
//    NSMutableData* signatureData = [NSMutableData data];
//    unsigned char zeroPadding[1] = {0,};
//
//    BIGNUM *r = NULL;
//    BIGNUM *s = NULL;
//
//    ECDSA_SIG_get0(signature, (const BIGNUM **)&r, (const BIGNUM **)&s);
//
//    NSData* rData = [PayOpenSSLHelper dataFromBN:r];
//
//    NSInteger rDataLen = rData.length;
//    for (NSInteger diff = 32 - rDataLen; diff > 0; --diff) {
//        [signatureData appendData:[NSData dataWithBytes:zeroPadding length:1]];
//    }
//    if (rData) {
//        [signatureData appendData:rData];
//    }
//
//    NSData* sData = [PayOpenSSLHelper dataFromBN:s];
//
//    NSInteger sDataLen = sData.length;
//    for (NSInteger diff = 32 - sDataLen; diff > 0; --diff) {
//        [signatureData appendData:[NSData dataWithBytes:zeroPadding length:1]];
//    }
//    if (sData) {
//        [signatureData appendData:sData];
//    }
//
//    if ([signatureData length] <= 0) {
//        //DebugLog(@"ECDSA_SIGN Data Error");
//        return nil;
//    }
//
//    base64EncodedSignature = [PayCertUtil base64UrlEncode:signatureData];
//    //DebugLog(@"%@", base64EncodedSignature);
//
//    return base64EncodedSignature;
//}

+ (NSDictionary<NSString *, id> *)payloadFromJWT:(NSString *)jwt withPEMCertificate:(NSString *)PEMCetificate {
    BOOL result = NO;
    
    NSString* header = nil;
    NSString* payload = nil;
    NSString* signature = nil;
    
    EC_KEY* ecKey = [PayOpenSSLHelper ecKeyWithPEMCertificate:PEMCetificate];
    if (!ecKey) {
        return nil;
    }
    
    NSArray* jwtComponents = [jwt componentsSeparatedByString:@"."];
    if (jwtComponents.count == 3) {
        header = jwtComponents[0];
        payload = jwtComponents[1];
        signature = jwtComponents[2];
        
        if (![header isKindOfClass:[NSString class]] || ![payload isKindOfClass:[NSString class]] || ![signature isKindOfClass:[NSString class]]) {
            return nil;
        }
    }
    
    if (header.length > 0 && payload.length > 0 && signature.length > 0) {
        
        NSString* headerAndPayload = [NSString stringWithFormat:@"%@.%@", header, payload];
        const unsigned char* data = (const unsigned char *)[headerAndPayload cStringUsingEncoding:NSUTF8StringEncoding];
        size_t length = [headerAndPayload length];
        
        unsigned char hash[SHA256_DIGEST_LENGTH] = {0,};
        
        SHA256_CTX sha256Ctx;
        SHA256_Init(&sha256Ctx);
        SHA256_Update(&sha256Ctx, data, length);
        SHA256_Final(hash, &sha256Ctx);
        
        NSData* signatureData = [PayCertUtil base64UrlDecode:signature];
        
        NSData* signatureDataR = [signatureData subdataWithRange:NSMakeRange(0, 32)];
        NSData* signatureDataS = [signatureData subdataWithRange:NSMakeRange([signatureData length]-32, 32)];
        
        BIGNUM *sigatureR = BN_bin2bn([signatureDataR bytes], (int)[signatureDataR length], NULL);
        BIGNUM *sigatureS = BN_bin2bn([signatureDataS bytes], (int)[signatureDataS length], NULL);
        
        ECDSA_SIG* ecdsaSig = ECDSA_SIG_new();
        ECDSA_SIG_set0(ecdsaSig, sigatureR, sigatureS);
        
        int verify_status = ECDSA_do_verify(hash, sizeof(hash), ecdsaSig, ecKey);
        if (verify_status) {
            result = YES;
        }
        
        if (ecdsaSig) {
            ECDSA_SIG_free(ecdsaSig);
        }
        
        if (result) {
            NSData* payloadData = [PayCertUtil base64UrlDecode:payload];
            NSString* payloadString = [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding];
            
            if (payloadString.length > 0) {
                NSData *jsonData = [payloadString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
            }
        }
    }
    return nil;
}

@end
