//
//  PayCrypto.m
//  KPCore
//
//  Created by kali_company on 2018. 3. 21..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

#import "PayCrypto.h"
#import "PayECKeyPair.h"
#import <CommonCrypto/CommonCrypto.h>
#import <openssl/evp.h>
#import <openssl/obj_mac.h>
#import <openssl/objects.h>
#import <openssl/sha.h>
#import <openssl/bn.h>
#import <openssl/ecdsa.h>

#import "PayOpenSSLHelper.h"

static const NSUInteger PayCryptoIVLength = 16;

static const int PayCryptoPBKDFKeyLength = 32;
static const int PayCryptoPBKDFIteration = 10000;


//
// Definition for "masked-out" areas of the base64DecodeLookup mapping
//
#define xxForPKI 65


//
// Mapping from URL safe ASCII character to 6 bit patter. (RFC 4648)
//
static unsigned char base64URLDecodeLookupForPKI[256] =
{
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, 62, xxForPKI, xxForPKI,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, xxForPKI, xxForPKI, xxForPKI, xxForPKI, 63,
    xxForPKI, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
    xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI, xxForPKI,
};

//
// Fundamental sizes of the binary and base64 encode/decode units in bytes
//
#define BINARY_UNIT_SIZE_FOR_PKI 3
#define BASE64_UNIT_SIZE_FOR_PKI 4

//
// NewBase64URLDecode (RFC 4648)
//
// Decodes the url safe base64 ASCII string in the inputBuffer to a newly malloced
// output buffer.
//
//  inputBuffer - the source ASCII string for the decode
//    length - the length of the string or -1 (to specify strlen should be used)
//    outputLength - if not-NULL, on output will contain the decoded length
//
// returns the decoded buffer. Must be free'd by caller. Length is given by
//    outputLength.
//
void *NewBase64URLDecodeForPKI(
                         const char *inputBuffer,
                         size_t length,
                         size_t *outputLength)
{
    if (length == -1)
    {
        length = strlen(inputBuffer);
    }
    
    size_t outputBufferSize =
    ((length+BASE64_UNIT_SIZE_FOR_PKI-1) / BASE64_UNIT_SIZE_FOR_PKI) * BINARY_UNIT_SIZE_FOR_PKI;
    unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
    
    size_t i = 0;
    size_t j = 0;
    while (i < length)
    {
        //
        // Accumulate 4 valid characters (ignore everything else)
        //
        unsigned char accumulated[BASE64_UNIT_SIZE_FOR_PKI];
        size_t accumulateIndex = 0;
        while (i < length)
        {
            unsigned char decode = base64URLDecodeLookupForPKI[inputBuffer[i++]];
            if (decode != xxForPKI)
            {
                accumulated[accumulateIndex] = decode;
                accumulateIndex++;
                
                if (accumulateIndex == BASE64_UNIT_SIZE_FOR_PKI)
                {
                    break;
                }
            }
        }
        
        //
        // Store the 6 bits from each of the 4 characters as 3 bytes
        //
        // (Uses improved bounds checking suggested by Alexandre Colucci)
        //
        if(accumulateIndex >= 2)
            outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);
        if(accumulateIndex >= 3)
            outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);
        if(accumulateIndex >= 4)
            outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
        j += accumulateIndex - 1;
    }
    
    if (outputLength)
    {
        *outputLength = j;
    }
    return outputBuffer;
}

@interface PayECKeyPair()
- (const EC_KEY*)ecKey;
@end

@implementation PayCrypto

+ (NSData *)SHA256:(NSData*)data {
    unsigned char hash[CC_SHA256_DIGEST_LENGTH] = {0,};
    
    CC_SHA256(data.bytes, (CC_LONG)data.length, hash);
    
    return [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
}

+ (NSData *)HmacSHA256:(NSData*)data key:(NSData*)key {
    unsigned char hash[CC_SHA256_DIGEST_LENGTH] = {0,};
    
    CCHmac(kCCHmacAlgSHA256, key.bytes, key.length, data.bytes, data.length, hash);
    
    return [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
}

+ (nullable NSData *)AES256Encrypt:(nonnull NSData *)plain iv:(nonnull NSData *)iv key:(nonnull NSData *)key {
    NSUInteger dataLength = [plain length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t cryptexLength = 0;
    NSData *cryptex = nil;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          (void*)[key bytes], kCCKeySizeAES256,
                                          (void*)[iv bytes],
                                          [plain bytes], dataLength,
                                          buffer, bufferSize,
                                          &cryptexLength);
    if (cryptStatus == kCCSuccess) {
        cryptex = [NSData dataWithBytes:buffer length:cryptexLength];
    }
    
    free(buffer);
    return cryptex;
}

+ (nullable NSData *)AES256Encrypt:(nonnull NSData *)plain key:(nonnull NSData *)key {
    NSData *iv = [key subdataWithRange:NSMakeRange(0, PayCryptoIVLength)];
    
    return [self AES256Encrypt:plain iv:iv key:key];
}

+ (nullable NSData *)AES256Decrypt:(nonnull NSData *)cryptex iv:(nonnull NSData *)iv key:(nonnull NSData *)key {
    NSUInteger dataLength = [cryptex length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t plainLength = 0;
    NSData *plain = nil;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          (void*)[key bytes], kCCKeySizeAES256,
                                          (void*)[iv bytes],
                                          [cryptex bytes], dataLength,
                                          buffer, bufferSize,
                                          &plainLength);
    
    if (cryptStatus == kCCSuccess) {
        plain = [NSData dataWithBytes:buffer length:plainLength];
    }
    
    free(buffer);
    return plain;
}

+ (nullable NSData *)AES256Decrypt:(nonnull NSData *)cryptex key:(nonnull NSData *)key {
    NSData *iv = [key subdataWithRange:NSMakeRange(0, PayCryptoIVLength)];
    
    return [self AES256Decrypt:cryptex iv:iv key:key];
}

+ (nullable NSData *)PBKDFKeyFromData:(nonnull NSData*)data salt:(nonnull NSData *)salt {
    unsigned char key[PayCryptoPBKDFKeyLength] = {0,};
    
    if(!PKCS5_PBKDF2_HMAC_SHA1(data.bytes, (int)data.length, salt.bytes, (int)salt.length, PayCryptoPBKDFIteration, PayCryptoPBKDFKeyLength, key)) {
        return nil;
    }
    NSData* pbkdfKey = [NSData dataWithBytes:key length:PayCryptoPBKDFKeyLength];
    //NSLog(@"pbkdfKey:%@", pbkdfKey);
    return pbkdfKey;
}

+ (nullable NSData *)DERSignatureWithEcKeyPair:(nonnull PayECKeyPair *)ecKeyPair data:(nonnull NSData *)inputData isNoneHash:(BOOL)isNoneHash {
    EC_KEY *ecKey = EC_KEY_dup(ecKeyPair.ecKey);
    
    if (!ecKey) {
        //DebugLog(@"ECKey is NULL");
        return nil;
    }
    
    unsigned char *hashedOrigianl = NULL;

    if (!isNoneHash) {
        const unsigned char* data = [inputData bytes];
        size_t length = [inputData length];
        
        unsigned char hash[SHA256_DIGEST_LENGTH] = {0,};
        
        SHA256_CTX sha256Ctx;
        SHA256_Init(&sha256Ctx);
        SHA256_Update(&sha256Ctx, data, length);
        SHA256_Final(hash, &sha256Ctx);
        
        hashedOrigianl = (unsigned char *)hash;
    } else {
        hashedOrigianl = (unsigned char *)inputData.bytes;
    }
    
    //NSData* hashData = [NSData dataWithBytes:hash length:SHA256_DIGEST_LENGTH];
    //DebugLog(@"hashData >> %@", hashData);
    
    ECDSA_SIG* signature = ECDSA_do_sign(hashedOrigianl, SHA256_DIGEST_LENGTH, ecKey);
    if (!signature) {
        //error
        //DebugLog(@"ECDSA_do_sign Error");
        return nil;
    }
    
    int verify_status = ECDSA_do_verify(hashedOrigianl, SHA256_DIGEST_LENGTH, signature, ecKey);
    if (!verify_status) {
        //error
        //DebugLog(@"ECDSA_do_verify Error");
        return nil;
    }
    
    uint8_t oneByteValue = 0;
    
    NSMutableData* signatureData = [NSMutableData data];
    NSMutableData* tempSignatureData = [NSMutableData data];
    
    BIGNUM *r = NULL;
    BIGNUM *s = NULL;
    
    ECDSA_SIG_get0(signature, (const BIGNUM **)&r, (const BIGNUM **)&s);
    
    NSData* rData = [PayOpenSSLHelper dataFromBN:r];
    if (rData) {
        oneByteValue = 0x02;
        [tempSignatureData appendBytes:&oneByteValue length:1];
        
        //first bit check
        unsigned char* rBytes = (unsigned char*)[rData bytes];
        if (rBytes[0] > 0x7f) {
            oneByteValue = [rData length] + 1;
            [tempSignatureData appendBytes:&oneByteValue length:1];
            oneByteValue = 0x00;
            [tempSignatureData appendBytes:&oneByteValue length:1];
        }
        else {
            oneByteValue = [rData length];
            [tempSignatureData appendBytes:&oneByteValue length:1];
        }
        
        [tempSignatureData appendData:rData];
    }
    NSData* sData = [PayOpenSSLHelper dataFromBN:s];
    if (sData) {
        oneByteValue = 0x02;
        [tempSignatureData appendBytes:&oneByteValue length:1];
        
        //first bit check
        unsigned char* sBytes = (unsigned char*)[sData bytes];
        if (sBytes[0] > 0x7f) {
            oneByteValue = [sData length] + 1;
            [tempSignatureData appendBytes:&oneByteValue length:1];
            oneByteValue = 0x00;
            [tempSignatureData appendBytes:&oneByteValue length:1];
        }
        else {
            oneByteValue = [sData length];
            [tempSignatureData appendBytes:&oneByteValue length:1];
        }
        [tempSignatureData appendData:sData];
    }
    
    oneByteValue = 0x30;
    [signatureData appendBytes:&oneByteValue length:1];
    if ([tempSignatureData length] > 0x7f) {
        oneByteValue = 0x00;
        [signatureData appendBytes:&oneByteValue length:1];
    }
    oneByteValue = [tempSignatureData length];
    [signatureData appendBytes:&oneByteValue length:1];
    [signatureData appendData:tempSignatureData];
    
    if ([signatureData length] <= 0) {
        //DebugLog(@"ECDSA_SIGN Data Error");
        return nil;
    }
    
    return signatureData;
}

+ (NSData *)signatureWithEcKeyPair:(PayECKeyPair *)ecKeyPair dataString:(NSString *)dataString {
    EC_KEY* ecKey = EC_KEY_dup(ecKeyPair.ecKey);
    
    if (!ecKey) {
        //DebugLog(@"ECKey is NULL");
        return nil;
    }
    
    const unsigned char* data = (const unsigned char *)[dataString cStringUsingEncoding:NSUTF8StringEncoding];
    size_t length = [dataString length];
    
    unsigned char hash[SHA256_DIGEST_LENGTH] = {0,};
    
    SHA256_CTX sha256Ctx;
    SHA256_Init(&sha256Ctx);
    SHA256_Update(&sha256Ctx, data, length);
    SHA256_Final(hash, &sha256Ctx);
    
    //NSData* hashData = [NSData dataWithBytes:hash length:SHA256_DIGEST_LENGTH];
    //DebugLog(@"hashData >> %@", hashData);
    
    ECDSA_SIG* signature = ECDSA_do_sign(hash, sizeof(hash), ecKey);
    if (!signature) {
        //error
        //DebugLog(@"ECDSA_do_sign Error");
        return nil;
    }
    
    int verify_status = ECDSA_do_verify(hash, sizeof(hash), signature, ecKey);
    if (!verify_status) {
        //error
        //DebugLog(@"ECDSA_do_verify Error");
        return nil;
    }
    NSMutableData* signatureData = [NSMutableData data];
    unsigned char zeroPadding[1] = {0,};
    
    BIGNUM *r = NULL;
    BIGNUM *s = NULL;
    
    ECDSA_SIG_get0(signature, (const BIGNUM **)&r, (const BIGNUM **)&s);
    
    NSData* rData = [PayOpenSSLHelper dataFromBN:r];
    
    NSInteger rDataLen = rData.length;
    for (NSInteger diff = 32 - rDataLen; diff > 0; --diff) {
        [signatureData appendData:[NSData dataWithBytes:zeroPadding length:1]];
    }
    if (rData) {
        [signatureData appendData:rData];
    }
    
    NSData* sData = [PayOpenSSLHelper dataFromBN:s];
    
    NSInteger sDataLen = sData.length;
    for (NSInteger diff = 32 - sDataLen; diff > 0; --diff) {
        [signatureData appendData:[NSData dataWithBytes:zeroPadding length:1]];
    }
    if (sData) {
        [signatureData appendData:sData];
    }
    
    if ([signatureData length] <= 0) {
        //DebugLog(@"ECDSA_SIGN Data Error");
        return nil;
    }
    
    return signatureData;
}

+ (nonnull NSData *)base64UrlDecodeForPKIFromEncodedString:(nonnull NSString *)encodedString {
    NSData *data = [encodedString dataUsingEncoding:NSASCIIStringEncoding];
    size_t outputLength;
    void *outputBuffer = NewBase64URLDecodeForPKI([data bytes], [data length], &outputLength);
    NSData *result = [NSData dataWithBytes:outputBuffer length:outputLength];
    free(outputBuffer);
    return result;
}
                                                     
@end
