//
//  KPAppIntegrity.m
//  KPCore
//
//  Created by kali_company on 2018. 5. 28..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

/*
 앱위변조 공격 비용 증가를 위해 class, function 이름을 임의로 변경 하였습니다.
 
 -> PayAppIntegrity.h 파일은 public header 로서 공개되기 때문에 파일명을 변경하여 다음에 위치합니다. KPCore>ImagePath>CFImagePathUtil.h
*/
#import "NSImagePathUtil.h"
#import "CFImagePathUtil.h"
#import "CFImageMetaSerializer.h"

@implementation NSImagePathUtil
+ (BOOL)commonPath {
    return [CFImagePathUtil commonPath];
}

+ (BOOL)relativePath {
    return [CFImagePathUtil relativePath];
}

+ (void)shutterSpeed {
    [CFImagePathUtil shutterSpeed];
}

+ (BOOL)serialize:(nonnull NSString *)pathString options:(unsigned char)options result:(nonnull NSInteger *)result {
    return [CFImageMetaSerializer serialize:pathString options:options result:result];
}
@end
