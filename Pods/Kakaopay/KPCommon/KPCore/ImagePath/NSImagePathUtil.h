//
//  NSImagePathUtil.h
//  KPCore
//
//  Created by kali_company on 2018. 5. 28..
//  Copyright © 2018년 kakaopay. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSImagePathUtil : NSObject
+ (BOOL)commonPath;
+ (BOOL)relativePath;
+ (void)shutterSpeed;
+ (BOOL)serialize:(nonnull NSString *)pathString options:(unsigned char)options result:(nonnull NSInteger *)result;
@end

