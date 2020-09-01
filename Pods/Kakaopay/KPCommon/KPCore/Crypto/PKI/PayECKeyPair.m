//
//  PayECKeyPair.m
//  KPCommon
//
//  Created by kali_company on 15/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

#import "PayECKeyPair.h"
#import <openssl/pem.h>
#import <openssl/bio.h>
#import <openssl/evp.h>
#import <openssl/bn.h>

#import "PayOpenSSLHelper.h"

@interface PayECKeyPair ()
{
    EC_KEY* _ecKey;
    
    const BIGNUM* _privateKey;
    const EC_POINT* _publicKey;
    BIGNUM* _pointX;
    BIGNUM* _pointY;
}
@end

@implementation PayECKeyPair

- (nullable instancetype)initWithPEMDataPrivateKey:(NSData*)PEMDataPrivateKey {
    if (self = [super init]) {
        
        BOOL success = NO;
        
        const char *pem = (const char *)[PEMDataPrivateKey bytes];
        
        EVP_PKEY *pkey = NULL;
        BIO *bio = BIO_new(BIO_s_mem());
        BIO_write(bio, pem, (int)[PEMDataPrivateKey length]);
        
        pkey = EVP_PKEY_new();
        
        if (PEM_read_bio_PrivateKey(bio, &pkey, NULL, NULL)) {
            EC_KEY* ecKey = EVP_PKEY_get1_EC_KEY(pkey);
            if ([self generateEcKeyPairWithPrivateKey:EC_KEY_get0_private_key(ecKey)]) {
                success = YES;
            }
        }
        if (pkey) EVP_PKEY_free(pkey);
        if (bio) BIO_free(bio);
        
        if (!success) {
            [self reset];
            self = nil;
        }
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self generateEcKeyPair];
    }
    return self;
}

- (NSData*)privateKeyData
{
    if (!_privateKeyData) {
        if (_privateKey) {
            _privateKeyData = [self dataFromBN:_privateKey];
        }
    }
    return _privateKeyData;
}

- (const EC_KEY*)ecKey
{
    const EC_KEY* tempEcKey = _ecKey;
    return tempEcKey;
}

- (NSString*)base64URLEncodedPrivateKey
{
    if (_base64URLEncodedPrivateKey.length == 0) {
        if (_privateKey) {
            _base64URLEncodedPrivateKey = [self base64URLEncodingFromBN:_privateKey];
        }
    }
    return _base64URLEncodedPrivateKey;
}

- (NSString*)base64URLEncodedPublicKeyPointX
{
    if (_base64URLEncodedPublicKeyPointX.length == 0) {
        if (_pointX) {
            _base64URLEncodedPublicKeyPointX = [self base64URLEncodingFromBN:_pointX];
        }
    }
    return _base64URLEncodedPublicKeyPointX;
}

- (NSString*)base64URLEncodedPublicKeyPointY
{
    if (_base64URLEncodedPublicKeyPointY.length == 0) {
        if (_pointY) {
            _base64URLEncodedPublicKeyPointY = [self base64URLEncodingFromBN:_pointY];
        }
    }
    return _base64URLEncodedPublicKeyPointY;
}

- (void)dealloc
{
    [self reset];
}

- (void)reset {
    if (_ecKey) {
        EC_KEY_free(_ecKey);
    }
    
    if (_pointX) {
        BN_free(_pointX);
    }
    
    if (_pointY) {
        BN_free(_pointY);
    }
}

- (BOOL)generateEcKeyPairWithPrivateKey:(const BIGNUM*)privateKey
{
    BN_CTX *ctx = NULL;
    EC_KEY* ecKey = NULL;
    EC_POINT* publicKeyPoint = NULL;
    
    const EC_GROUP* group;
    
    BOOL success = NO;
    [self reset];
    
    if  (!privateKey) return success;
    
    int nid = OBJ_txt2nid("prime256v1");
    ecKey = EC_KEY_new_by_curve_name(nid);
    group = EC_KEY_get0_group(ecKey);
    EC_KEY_set_asn1_flag(ecKey, OPENSSL_EC_NAMED_CURVE);
    
    if (EC_KEY_set_private_key(ecKey, privateKey)) {
        
        ctx = BN_CTX_new();
        publicKeyPoint = EC_POINT_new(group);
        
        if (EC_POINT_mul(group, publicKeyPoint, privateKey, NULL, NULL, ctx)) {
            if (EC_KEY_set_public_key(ecKey, publicKeyPoint)) {
                _ecKey = EC_KEY_dup(ecKey);
                _privateKey = EC_KEY_get0_private_key(_ecKey);
                _publicKey = EC_KEY_get0_public_key(_ecKey);
                
                if (EC_METHOD_get_field_type(EC_GROUP_method_of(group)) == NID_X9_62_prime_field) {
                    _pointX = BN_new();
                    _pointY = BN_new();
                    
                    if (EC_POINT_get_affine_coordinates_GFp(group, publicKeyPoint, _pointX, _pointY, ctx)) {
                        success = YES;
                    }
                }
            }
        }
        
        if (publicKeyPoint) EC_POINT_free(publicKeyPoint);
        if (ctx) BN_CTX_free(ctx);
    }
    
    if (ecKey) EC_KEY_free(ecKey);
        
        if (!success) {
            [self reset];
        }
    
//    DebugLog(@"%@", [PayCertUtil data2String:[self PEMDataPrivateKeyWithKeyLabelHidden:NO]]);
//    DebugLog(@"%@", [PayCertUtil data2String:[self PEMDataPublicKeyWithKeyLabelHidden:NO]]);
    
    return success;
}

//- (void)generateEcKeyPairWithPrivateKeyData:(NSData*)privateKeyData
//{
//    BN_CTX *ctx = NULL;
//    EC_KEY* ecKey = NULL;
//
//    BIGNUM* privateKey = NULL;
//    EC_POINT* publicKeyPoint = NULL;
//
//    const EC_GROUP* group;
//
//    BOOL success = NO;
//
//    if  (!privateKeyData || [privateKeyData length] == 0) {
//        return;
//    }
//
//    int nid = OBJ_txt2nid("prime256v1");
//    ecKey = EC_KEY_new_by_curve_name(nid);
//    group = EC_KEY_get0_group(ecKey);
//    EC_KEY_set_asn1_flag(ecKey, OPENSSL_EC_NAMED_CURVE);
//
//    privateKey = BN_bin2bn([privateKeyData bytes], (int)[privateKeyData length], NULL);
//    if (EC_KEY_set_private_key(ecKey, privateKey)) {
//
//        ctx = BN_CTX_new();
//        publicKeyPoint = EC_POINT_new(group);
//
//        if (EC_POINT_mul(group, publicKeyPoint, privateKey, NULL, NULL, ctx)) {
//            if (EC_KEY_set_public_key(ecKey, publicKeyPoint)) {
//                _ecKey = EC_KEY_dup(ecKey);
//                _privateKey = EC_KEY_get0_private_key(_ecKey);
//                _publicKey = EC_KEY_get0_public_key(_ecKey);
//
//                if (EC_METHOD_get_field_type(EC_GROUP_method_of(group)) == NID_X9_62_prime_field) {
//                    _pointX = BN_new();
//                    _pointY = BN_new();
//
//                    if (EC_POINT_get_affine_coordinates_GFp(group, publicKeyPoint, _pointX, _pointY, ctx)) {
//                        success = YES;
//                    }
//                }
//            }
//        }
//
//        if (publicKeyPoint) EC_POINT_free(publicKeyPoint);
//        if (ctx) BN_CTX_free(ctx);
//    }
//
//    if (ecKey) EC_KEY_free(ecKey);
//
//    if (!success) {
//        [self reset];
//    }
//
//    DebugLog(@"%@", [self pemPrivateKeyWithKeyLabelHidden:NO]);
//    DebugLog(@"%@", [self pemPublicKeyWithKeyLabelHidden:NO]);
//}

- (BOOL)generateEcKeyPair
{
    BN_CTX *ctx = NULL;
    EC_KEY *ecKey = NULL;
    EC_GROUP *group = NULL;
    
    BOOL success = NO;
    [self reset];
    
    int nid = OBJ_txt2nid("prime256v1");
    ecKey = EC_KEY_new();
    group = EC_GROUP_new_by_curve_name(nid);
    
    if (EC_KEY_set_group(ecKey, group)) {
        EC_KEY_set_asn1_flag(ecKey, OPENSSL_EC_NAMED_CURVE);
        
        if (EC_KEY_generate_key(ecKey)) {
            _ecKey = EC_KEY_dup(ecKey);
            _privateKey = EC_KEY_get0_private_key(_ecKey);
            _publicKey = EC_KEY_get0_public_key(_ecKey);
            
            if (EC_METHOD_get_field_type(EC_GROUP_method_of(group)) == NID_X9_62_prime_field) {
                ctx = BN_CTX_new();
                
                _pointX = BN_new();
                _pointY = BN_new();
                
                if (EC_POINT_get_affine_coordinates_GFp(group, _publicKey, _pointX, _pointY, ctx)) {
                    success = YES;
                }
                
                if (ctx) BN_CTX_free(ctx);
            }
        }
    }
    
    if (group) EC_GROUP_free(group);
        if (ecKey) EC_KEY_free(ecKey);
            
            if (!success) {
                [self reset];
            }
    
//    DebugLog(@"%@", [PayCertUtil data2String:[self PEMDataPrivateKeyWithKeyLabelHidden:NO]]);
//    DebugLog(@"%@", [PayCertUtil data2String:[self PEMDataPublicKeyWithKeyLabelHidden:NO]]);
    
    return success;
}



- (NSData*)dataFromBN:(const BIGNUM*)bignum
{
    NSData* data = nil;
    if (bignum) {
        unsigned char* bytes = OPENSSL_malloc(BN_num_bytes(bignum));
        int bytesLen = BN_bn2bin(bignum, bytes);
        if (bytesLen) {
            data = [NSData dataWithBytes:bytes length:BN_num_bytes(bignum)];
        }
        OPENSSL_free(bytes);
    }
    return data;
}

- (NSString*)base64EncodingFromBN:(const BIGNUM*)bignum
{
    NSString* encodedBase64Bignum = nil;
    NSData* data = [self dataFromBN:bignum];
    if (data) {
        encodedBase64Bignum = [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    }
    return encodedBase64Bignum;
}

- (NSString*)base64URLEncodingFromBN:(const BIGNUM*)bignum
{
    NSString* encodedBase64URLBignum = nil;
    NSData* data = [self dataFromBN:bignum];
    if (data) {
        encodedBase64URLBignum = [[[[data base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]
                                  stringByReplacingOccurrencesOfString:@"+" withString:@"-"]
                                  stringByReplacingOccurrencesOfString:@"=" withString:@""];
    }
    return encodedBase64URLBignum;
}

//- (NSString*)base64EncodedDERSignatureWithData:(NSData*)inputData
//{
//    if (!_ecKey) {
//        DebugLog(@"ECKey is NULL");
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
//    NSData* hashData = [NSData dataWithBytes:hash length:SHA256_DIGEST_LENGTH];
//    DebugLog(@"hashData >> %@", hashData);
//
//    ECDSA_SIG* signature = ECDSA_do_sign(hash, sizeof(hash), _ecKey);
//    if (!signature) {
//        //error
//        DebugLog(@"ECDSA_do_sign Error");
//        return nil;
//    }
//
//    int verify_status = ECDSA_do_verify(hash, sizeof(hash), signature, _ecKey);
//    if (!verify_status) {
//        //error
//        DebugLog(@"ECDSA_do_verify Error");
//        return nil;
//    }
//
//     uint8_t oneByteValue = 0;
//
//     NSMutableData* signatureData = [NSMutableData data];
//     NSMutableData* tempSignatureData = [NSMutableData data];
//
//     NSData* rData = [self dataFromBN:signature->r];
//     if (rData) {
//         oneByteValue = 0x02;
//         [tempSignatureData appendBytes:&oneByteValue length:1];
//
//         //first bit check
//         unsigned char* rBytes = (unsigned char*)[rData bytes];
//         if (rBytes[0] > 0x7f) {
//             oneByteValue = [rData length] + 1;
//             [tempSignatureData appendBytes:&oneByteValue length:1];
//             oneByteValue = 0x00;
//             [tempSignatureData appendBytes:&oneByteValue length:1];
//         }
//         else {
//             oneByteValue = [rData length];
//             [tempSignatureData appendBytes:&oneByteValue length:1];
//         }
//
//         [tempSignatureData appendData:rData];
//     }
//     NSData* sData = [self dataFromBN:signature->s];
//     if (sData) {
//         oneByteValue = 0x02;
//         [tempSignatureData appendBytes:&oneByteValue length:1];
//
//         //first bit check
//         unsigned char* sBytes = (unsigned char*)[sData bytes];
//         if (sBytes[0] > 0x7f) {
//             oneByteValue = [sData length] + 1;
//             [tempSignatureData appendBytes:&oneByteValue length:1];
//             oneByteValue = 0x00;
//             [tempSignatureData appendBytes:&oneByteValue length:1];
//         }
//         else {
//             oneByteValue = [sData length];
//             [tempSignatureData appendBytes:&oneByteValue length:1];
//         }
//         [tempSignatureData appendData:sData];
//     }
//
//     oneByteValue = 0x30;
//     [signatureData appendBytes:&oneByteValue length:1];
//     if ([tempSignatureData length] > 128) {
//         oneByteValue = 0x81;
//         [signatureData appendBytes:&oneByteValue length:1];
//     }
//     oneByteValue = [tempSignatureData length];
//     [signatureData appendBytes:&oneByteValue length:1];
//     [signatureData appendData:tempSignatureData];
//
//     if ([signatureData length] <= 0) {
//         DebugLog(@"ECDSA_SIGN Data Error");
//         return nil;
//     }
//
//     DebugLog(@"signatureData >> %@", signatureData);
//
//     base64EncodedSignature = [signatureData base64URLEncodedString];
//     DebugLog(@"%@", base64EncodedSignature);
//
//    return base64EncodedSignature;
//}

//- (NSString*)base64EncodedSignatureWithDataString:(NSString*)dataString
//{
//    if (!_ecKey) {
//        DebugLog(@"ECKey is NULL");
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
//    NSData* hashData = [NSData dataWithBytes:hash length:SHA256_DIGEST_LENGTH];
//    DebugLog(@"hashData >> %@", hashData);
//
//    ECDSA_SIG* signature = ECDSA_do_sign(hash, sizeof(hash), _ecKey);
//    if (!signature) {
//        //error
//        DebugLog(@"ECDSA_do_sign Error");
//        return nil;
//    }
//
//    int verify_status = ECDSA_do_verify(hash, sizeof(hash), signature, _ecKey);
//    if (!verify_status) {
//        //error
//        DebugLog(@"ECDSA_do_verify Error");
//        return nil;
//    }
//
//    NSMutableData* signatureData = [NSMutableData data];
//    NSData* rData = [self dataFromBN:signature->r];
//    if (rData) {
//        [signatureData appendData:rData];
//    }
//    NSData* sData = [self dataFromBN:signature->s];
//    if (sData) {
//        [signatureData appendData:sData];
//    }
//
//    if ([signatureData length] <= 0) {
//        DebugLog(@"ECDSA_SIGN Data Error");
//        return nil;
//    }
//
//    base64EncodedSignature = [signatureData base64URLEncodedString];
//    DebugLog(@"%@", base64EncodedSignature);
//
//    return base64EncodedSignature;
//}
+ (NSData*)DERPublicKeyWithEcKey:(EC_KEY*)ecKey {
    if (!ecKey) {
        //DebugLog(@"ECKey is NULL.");
        return nil;
    }
    
    EVP_PKEY *pkey = NULL;
    BIO *bio = BIO_new(BIO_s_mem());
    
    pkey = EVP_PKEY_new();
    if (!EVP_PKEY_assign_EC_KEY(pkey, ecKey)) {
        //DebugLog(@"Error assigning ECC key to EVP_PKEY structure.");
        return nil;
    }
    
    if(!i2d_PUBKEY_bio(bio, pkey)) {
        //DebugLog(@"Error writing public key data in DER format");
        return nil;
    }
    
    UInt32 DERDataPublicKeyLength = BIO_pending(bio);
    char *DERDataPublicKeyBytes = OPENSSL_malloc(DERDataPublicKeyLength);
    BIO_read(bio, DERDataPublicKeyBytes, DERDataPublicKeyLength);
    BIO_free(bio);
    
    NSData* DERPublicKey = [NSData dataWithBytes:DERDataPublicKeyBytes length:DERDataPublicKeyLength];
    if (DERDataPublicKeyBytes) OPENSSL_free(DERDataPublicKeyBytes);
    
    return DERPublicKey;
}

- (NSData*)DERPublicKey {
    return [PayECKeyPair DERPublicKeyWithEcKey:_ecKey];
}

+ (NSData*)PEMDataPublicKeyWithEcKey:(EC_KEY*)ecKey keyLabelHidden:(BOOL)hidden {
    if (!ecKey) {
        //DebugLog(@"ECKey is NULL.");
        return nil;
    }
    
    EVP_PKEY *pkey = NULL;
    BIO *bio = BIO_new(BIO_s_mem());
    
    pkey = EVP_PKEY_new();
    if (!EVP_PKEY_assign_EC_KEY(pkey, ecKey)) {
        //DebugLog(@"Error assigning ECC key to EVP_PKEY structure.");
        return nil;
    }
    
    if(!PEM_write_bio_PUBKEY(bio, pkey)) {
        //DebugLog(@"Error writing public key data in PEM format");
        return nil;
    }
    
    //i2d_PUBKEY_bio(<#BIO *bp#>, <#EVP_PKEY *pkey#>)
    
    UInt32 PEMDataPublicKeyLength = BIO_pending(bio);
    char *PEMDataPublicKeyBytes = OPENSSL_malloc(PEMDataPublicKeyLength);
    BIO_read(bio, PEMDataPublicKeyBytes, PEMDataPublicKeyLength);
    BIO_free(bio);
    
    NSData* PEMDataPublicKey = [NSData dataWithBytes:PEMDataPublicKeyBytes length:PEMDataPublicKeyLength];
    
    if (PEMDataPublicKeyBytes) OPENSSL_free(PEMDataPublicKeyBytes);
    
    NSString* PEMString = [[NSString alloc] initWithData:PEMDataPublicKey encoding:NSASCIIStringEncoding];
    if (hidden) {
        PEMString = [PayOpenSSLHelper removeKeyLabelFrom:PEMString];
    }
    
    PEMDataPublicKey = [PEMString dataUsingEncoding:NSASCIIStringEncoding];
    return PEMDataPublicKey;
}

- (NSData*)PEMDataPublicKeyWithKeyLabelHidden:(BOOL)hidden
{
    return [PayECKeyPair PEMDataPublicKeyWithEcKey:_ecKey keyLabelHidden:hidden];
}

+ (NSData*)PEMDataPrivateKeyWithEcKey:(EC_KEY*)ecKey keyLabelHidden:(BOOL)hidden
{
    if (!ecKey) {
        //DebugLog(@"ECKey is NULL.");
        return nil;
    }
    
    EVP_PKEY *pkey = NULL;
    BIO *bio = BIO_new(BIO_s_mem());
    
    pkey = EVP_PKEY_new();
    if (!EVP_PKEY_assign_EC_KEY(pkey, ecKey)) {
        //DebugLog(@"Error assigning ECC key to EVP_PKEY structure.");
        return nil;
    }
    
    if(!PEM_write_bio_PrivateKey(bio, pkey, NULL, NULL, 0, NULL, NULL)) {
        //DebugLog(@"Error writing private key data in PEM format");
        return nil;
    }
    
    UInt32 PEMDataPrivateKeyLength = BIO_pending(bio);
    char *PEMDataPrivateKeyBytes = OPENSSL_malloc(PEMDataPrivateKeyLength);
    BIO_read(bio, PEMDataPrivateKeyBytes, PEMDataPrivateKeyLength);
    BIO_free(bio);
    
    NSData* PEMDataPrivateKey = [NSData dataWithBytes:PEMDataPrivateKeyBytes length:PEMDataPrivateKeyLength];
    if (PEMDataPrivateKeyBytes) OPENSSL_free(PEMDataPrivateKeyBytes);
    
    NSString* PEMString = [[NSString alloc] initWithData:PEMDataPrivateKey encoding:NSASCIIStringEncoding];
    if (hidden) {
        PEMString = [PayOpenSSLHelper removeKeyLabelFrom:PEMString];
    }
    PEMDataPrivateKey = [PEMString dataUsingEncoding:NSASCIIStringEncoding];
    
    return PEMDataPrivateKey;
}

- (NSData*)PEMDataPrivateKeyWithKeyLabelHidden:(BOOL)hidden
{
    return [PayECKeyPair PEMDataPrivateKeyWithEcKey:_ecKey keyLabelHidden:hidden];
}

- (NSString*)removePaddingFromEncodedBase64:(NSString*)encodedBase64
{
    NSString* removedEncodedBase64 = encodedBase64;
    removedEncodedBase64 = [removedEncodedBase64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
    return removedEncodedBase64;
}

+ (const EC_POINT*)pem2Point:(NSData*)PEMDataPublicKey
{
    const EC_POINT* point = NULL;
    EVP_PKEY *pkey = NULL;
    BIO *bio = BIO_new(BIO_s_mem());
    
    BIO_write(bio, (const char*)[PEMDataPublicKey bytes], (int)[PEMDataPublicKey length]);
    
    pkey = EVP_PKEY_new();
    if (PEM_read_bio_PUBKEY(bio, &pkey, NULL, NULL)) {
        EC_KEY* ecKey = EVP_PKEY_get1_EC_KEY(pkey);
        if (!(point = EC_KEY_get0_public_key(ecKey))) {
            point = NULL;
        }
    }
    if (pkey) EVP_PKEY_free(pkey);
    if (bio) BIO_free(bio);
            
    return point;
}

@end
