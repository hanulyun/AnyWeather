//
//  PayCertUtil.h
//  KPCommon
//
//  Created by kali_company on 16/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayCertUtil : NSObject

+ (NSData *)base64UrlDecode:(NSString *)base64String;
+ (NSString *)base64UrlEncode:(NSData *)original;

@end

NS_ASSUME_NONNULL_END
