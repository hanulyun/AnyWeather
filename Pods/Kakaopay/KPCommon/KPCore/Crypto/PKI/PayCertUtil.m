//
//  PayCertUtil.m
//  KPCommon
//
//  Created by kali_company on 16/10/2018.
//  Copyright © 2018 kakaopay. All rights reserved.
//

#import "PayCertUtil.h"

@implementation PayCertUtil

+ (NSData *)base64UrlDecode:(NSString *)base64UrlString {
    NSString * base64String = [[base64UrlString stringByReplacingOccurrencesOfString:@"_" withString:@"/"]
                               stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    NSInteger padLength = (4 - (base64String.length % 4)) % 4;
    NSMutableString * base64StringWithPadding = [NSMutableString stringWithString:base64String];
    for (NSInteger i = 0; i < padLength; ++i) {
        [base64StringWithPadding appendString:@"="];
    }
    
    return [[NSData alloc] initWithBase64EncodedString:base64StringWithPadding options:0];
}

+ (NSString *)base64UrlEncode:(NSData *)original {
    return [[[[original base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]
             stringByReplacingOccurrencesOfString:@"+" withString:@"-"]
            stringByReplacingOccurrencesOfString:@"=" withString:@""];
}

@end
