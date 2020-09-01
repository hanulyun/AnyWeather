//
//  CFImageMetaSerializer.h
//  Pods
//
//  Created by henry.my on 2019/11/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CFImageMetaSerializer : NSObject
+ (BOOL)serialize:(nonnull NSString *)pathString options:(unsigned char)options result:(nonnull NSInteger *)result;
@end

NS_ASSUME_NONNULL_END
