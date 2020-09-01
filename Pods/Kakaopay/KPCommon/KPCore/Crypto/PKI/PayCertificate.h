//
//  PayCertificate.h
//  KPCommon
//
//  Created by kali_company on 15/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PayCertificateStatus) {
    PayCertificateStatusNone = 0,
    PayCertificateStatusGood,
    PayCertificateStatusBlock,
    PayCertificateStatusExpired,
    PayCertificateStatusRevoked
};


@interface PayCertificate : NSObject
@property (nonatomic, readonly) NSString* PEMCertificate;
@property (nonatomic, readonly) NSData* DERCertificate;

@property (nonatomic, readonly) NSString* serial;             // 발급번호
@property (nonatomic, readonly) NSString* subject;            // 발급자
@property (nonatomic, readonly) NSString* issuer;             // 발급기관
@property (nonatomic, readonly) NSString* constraint;         // 일반
@property (nonatomic, readonly) NSString* usage;              // 개인
@property (nonatomic, readonly) NSDate* issueDate;            // 발급날짜
@property (nonatomic, readonly) NSDate* expireDate;           // 만료날짜


- (nullable instancetype)initWithPEMCertificate:(NSString *)PEMCertificate;
- (nullable instancetype)initWithPEMCertificateInfo:(NSDictionary *)PEMCertificateInfo;

+ (PayCertificateStatus)certificateStatus:(NSString*)statusCode;
- (id)toString;

@end

NS_ASSUME_NONNULL_END
