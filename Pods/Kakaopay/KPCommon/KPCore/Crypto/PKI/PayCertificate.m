//
//  PayCertificate.m
//  KPCommon
//
//  Created by kali_company on 15/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

#import "PayCertificate.h"
#import "PayOpenSSLHelper.h"

#import <openssl/ec.h>
#import <openssl/bio.h>
#import <openssl/err.h>
#import <openssl/pem.h>
#import <openssl/x509.h>
#import <openssl/ossl_typ.h>
#import <openssl/bn.h>
#import <openssl/asn1.h>

@interface PayCertificate ()
{
    X509* _x509;
}
@property (nonatomic, readwrite) NSString* PEMCertificate;
@property (nonatomic, readwrite) NSData* DERCertificate;


@property (nonatomic, readwrite) NSString* serial;             // 발급번호
@property (nonatomic, readwrite) NSString* subject;            // 발급자
@property (nonatomic, readwrite) NSString* issuer;             // 발급기관
@property (nonatomic, readwrite) NSString* constraint;         // 일반
@property (nonatomic, readwrite) NSString* usage;              // 개인
@property (nonatomic, readwrite) NSDate* issueDate;            // 발급날짜
@property (nonatomic, readwrite) NSDate* expireDate;           // 만료날짜
@end

@implementation PayCertificate

- (nullable instancetype)initWithPEMCertificate:(NSString *)PEMCertificate
{
    if (self = [super init]) {
        _x509 = nil;
        if (PEMCertificate && [PEMCertificate isKindOfClass:[NSString class]]) {
            _PEMCertificate = PEMCertificate;
            [self decodeX509Certificate:_PEMCertificate];
        }
        else {
            self = nil;
        }
    }
    return self;
}

- (nullable instancetype)initWithPEMCertificateInfo:(NSDictionary*)PEMCertificateInfo
{
    if (self = [super init]) {
        _x509 = nil;
        NSString * PEMCertificate = PEMCertificateInfo[@"certificate"];
        if ([PEMCertificate isKindOfClass:[NSString class]]) {
            _PEMCertificate = PEMCertificate;
            [self decodeX509Certificate:_PEMCertificate];
        }
        else {
            self = nil;
        }
    }
    return self;
}

- (void)decodeX509Certificate:(NSString*)PEMCertificate
{
    if (PEMCertificate.length == 0) return;
    
    BIO *bio = BIO_new(BIO_s_mem());
    
    const char *x509bytes = [PEMCertificate cStringUsingEncoding:NSASCIIStringEncoding];
    BIO_write(bio, x509bytes, (int)[PEMCertificate length]);
    
    if ((_x509 = PEM_read_bio_X509(bio, NULL, 0, NULL))) {
        ASN1_INTEGER *asn1Serial = X509_get_serialNumber(_x509);
        _serial = [self decimalStringFromAsn1Integer:asn1Serial];
        
        ASN1_TIME *notBeforeTime = X509_getm_notBefore(_x509);
        _issueDate = [self dateFromAsn1Time:notBeforeTime];
        
        ASN1_TIME *notAfterTime = X509_getm_notAfter(_x509);
        _expireDate = [self dateFromAsn1Time:notAfterTime];
        
        X509_NAME *x509SubjectName = X509_get_subject_name(_x509);
        _subject = [self stringFromX509Name:x509SubjectName key:"CN"];
        
        X509_NAME *x509IssuerName = X509_get_issuer_name(_x509);
        _issuer = [self stringFromX509Name:x509IssuerName key:"O"]; // organization
        
        _constraint = @"일반"; //일반
        _usage = @"개인";      //개인
        
        _DERCertificate = [self convertDERFromPEM:PEMCertificate];
        
        NSLog(@"der:%@", _DERCertificate);
    }
    
    BIO_free(bio);
}

- (NSData*)convertDERFromPEM:(NSString*)PEMCertificate
{
    NSString* tempPEMCertificate = [PayOpenSSLHelper removeKeyLabelFrom:PEMCertificate];
    tempPEMCertificate = [tempPEMCertificate stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return [[NSData alloc] initWithBase64EncodedString:tempPEMCertificate options:0];
}

- (NSString*)decimalStringFromAsn1Integer:(ASN1_INTEGER*)asn1Integer
{
    NSString* string = nil;
    if (asn1Integer) {
        BIGNUM *bn = ASN1_INTEGER_to_BN(asn1Integer, NULL);
        const char *asciiDecimal = BN_bn2dec(bn);
        string = [NSString stringWithUTF8String:asciiDecimal];
    }
    return string;
}

- (NSString*)stringFromX509Name:(X509_NAME*)x509Name key:(const char*)key
{
    NSString* string = nil;
    if  (x509Name && key ) {
        int nid = OBJ_txt2nid(key);
        if (nid != NID_undef) {
            int index = X509_NAME_get_index_by_NID(x509Name, nid, -1);
            
            X509_NAME_ENTRY *x509NameEntry = X509_NAME_get_entry(x509Name, index);
            if (x509NameEntry ) {
                ASN1_STRING *asn1String = X509_NAME_ENTRY_get_data(x509NameEntry);
                
                if (asn1String ) {
                    const unsigned char *name = ASN1_STRING_get0_data(asn1String);
                    string = [NSString stringWithUTF8String:(char*)name];
                }
            }
        }
    }
    
    return string;
}

- (NSDate*)dateFromAsn1Time:(ASN1_TIME*)asn1Time
{
    NSDate* date = nil;
    
    if (asn1Time != NULL) {
        ASN1_GENERALIZEDTIME *asn1GeneralizedTime = ASN1_TIME_to_generalizedtime(asn1Time, NULL);
        if (asn1GeneralizedTime != NULL) {
            const unsigned char *asn1TimeData = ASN1_STRING_get0_data(asn1GeneralizedTime);
            
            // ASN1 generalized times look like this: "20131114230046Z"
            //                                format:  YYYYMMDDHHMMSS
            //                               indices:  01234567890123
            //                                                   1111
            // There are other formats (e.g. specifying partial seconds or
            // time zones) but this is good enough for our purposes since
            // we only use the date and not the time.
            //
            // (Source: http://www.obj-sys.com/asn1tutorial/node14.html)
            
            NSString *asn1TimeString = [NSString stringWithUTF8String:(char *)asn1TimeData];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            
            dateComponents.year   = [[asn1TimeString substringWithRange:NSMakeRange(0, 4)] intValue];
            dateComponents.month  = [[asn1TimeString substringWithRange:NSMakeRange(4, 2)] intValue];
            dateComponents.day    = [[asn1TimeString substringWithRange:NSMakeRange(6, 2)] intValue];
            dateComponents.hour   = [[asn1TimeString substringWithRange:NSMakeRange(8, 2)] intValue];
            dateComponents.minute = [[asn1TimeString substringWithRange:NSMakeRange(10, 2)] intValue];
            dateComponents.second = [[asn1TimeString substringWithRange:NSMakeRange(12, 2)] intValue];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            date = [calendar dateFromComponents:dateComponents];
        }
    }
    return date;
}

+ (PayCertificateStatus)certificateStatus:(NSString*)statusCode
{
    PayCertificateStatus certificateStatus = PayCertificateStatusNone;
    
    if ([statusCode isKindOfClass:[NSString class]] && (statusCode.length > 0)) {
        if ([statusCode isEqualToString:@"GOOD"]) {
            certificateStatus = PayCertificateStatusGood;
        }
        else if ([statusCode isEqualToString:@"BLOCK"]){
            certificateStatus = PayCertificateStatusBlock;
        }
        else if ([statusCode isEqualToString:@"EXPIRED"]){
            certificateStatus = PayCertificateStatusExpired;
        }
        else if ([statusCode isEqualToString:@"REVOKED"]){
            certificateStatus = PayCertificateStatusRevoked;
        }
    }
    return certificateStatus;
}

- (id)toString {
    NSMutableString *resultString = [NSMutableString stringWithString:@"\n"];
    [resultString appendFormat:@"serial:[%@]\r", self.serial];
    [resultString appendFormat:@"subject:[%@]\r", self.subject];
    [resultString appendFormat:@"issuer:[%@]\r", self.issuer];
    [resultString appendFormat:@"constraint:[%@]\r", self.constraint];
    [resultString appendFormat:@"usage:[%@]\r", self.usage];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy.MM.dd"];
    
    NSString* issueDateString = [dateFormat stringFromDate:self.issueDate];
    [resultString appendFormat:@"not before:[%@]\r", issueDateString];
    
    NSString* expireDateString = [dateFormat stringFromDate:self.expireDate];
    [resultString appendFormat:@"not notAfter:[%@]\r", expireDateString];
    
    return resultString;
}

@end

