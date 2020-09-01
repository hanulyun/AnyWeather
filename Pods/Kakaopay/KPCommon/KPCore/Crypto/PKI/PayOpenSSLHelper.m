//
//  PayOpenSSLHelper.m
//  KPCommon
//
//  Created by kali_company on 15/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

#import "PayOpenSSLHelper.h"

#import <openssl/pem.h>
#import <openssl/bn.h>
#import <openssl/ossl_typ.h>

@implementation PayOpenSSLHelper

+ (EC_KEY*)ecKeyWithPEMCertificate:(NSString*)PEMCertificate
{
    X509* x509ServerCert = NULL;
    EVP_PKEY *pKey = NULL;
    EC_KEY* ecKey = NULL;
    
    BIO *bio = BIO_new(BIO_s_mem());
    
    const char *x509bytes = [PEMCertificate cStringUsingEncoding:NSASCIIStringEncoding];
    BIO_write(bio, x509bytes, (int)[PEMCertificate length]);
    
    if ((x509ServerCert = PEM_read_bio_X509(bio, NULL, 0, NULL))) {
        if ((pKey = X509_get_pubkey(x509ServerCert))) {
            ecKey = EVP_PKEY_get1_EC_KEY(pKey);
            
//            NSString* PEMPublicKey = [[NSString alloc] initWithData:[PayECKeyPair PEMDataPublicKeyWithEcKey:ecKey keyLabelHidden:NO] encoding:NSASCIIStringEncoding];
//            DebugLog(@"ServerSide Certificate PublicKey:");
//            DebugLog(@"%@", PEMPublicKey);
        }
    }
    
    BIO_free(bio);
    
    return ecKey;
}

+ (NSString *)removeKeyLabelFrom:(NSString *)key {
    //ec key
    key = [key stringByReplacingOccurrencesOfString:@"-----BEGIN PRIVATE KEY-----" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"-----END PRIVATE KEY-----" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----" withString:@""];
    
    //certificate
    key = [key stringByReplacingOccurrencesOfString:@"-----BEGIN CERTIFICATE-----" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"-----END CERTIFICATE-----" withString:@""];
    
    return key;
}

+ (nullable NSData *)dataFromBN:(const BIGNUM *)bn {
    NSData * data = nil;
    if (bn) {
        unsigned char* bytes = OPENSSL_malloc(BN_num_bytes(bn));
        int bytesLen = BN_bn2bin(bn, bytes);
        if (bytesLen) {
            data = [NSData dataWithBytes:bytes length:BN_num_bytes(bn)];
        }
        OPENSSL_free(bytes);
    }
    return data;
}

@end
