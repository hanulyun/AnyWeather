//
//  PayCodehashCheker.m
//  Pods
//
//  Created by henry.my on 2019/11/12.
//

#import "CFImageMetaSerializer.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include "lib_image_path_util.h"
#include "lib_image_defines.h"

@implementation CFImageMetaSerializer

+ (BOOL)serialize:(nonnull NSString *)pathString options:(unsigned char)options result:(nonnull NSInteger *)result {
    int ret = RET_IMAGE_FAIL;
    ret = image_get_path([pathString UTF8String], options);
    *result = ret;
    /*
     comment:
     리얼 환경에 배포해본 적이 없기 때문에 안전성이 담보될 때 까지 fail 상황은 성공으로 간주하여 by pass 될 수 있도록 하고 명확하게 invalid 상황일 경우만 false 를 return.
     추후 티아라 로그 등을 통해 fail 상황이 발생하는지 여부를 모니터링 하고 운영에 문제가 없다고 판단되면 valid 만 보도록 변경 가능.
     */
    return (ret == RET_IMAGE_VALID || ret == RET_IMAGE_FAIL);
}

@end
