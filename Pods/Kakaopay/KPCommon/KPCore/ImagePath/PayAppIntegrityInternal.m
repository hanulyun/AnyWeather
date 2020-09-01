//
//  ImagePathUtil.m
//  KPCore
//
//  Created by kali_company on 2018. 5. 28..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

#import "CFImagePathUtil.h"

#include <sys/stat.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>
#include <dlfcn.h>
#include <stdio.h>

//typedef NS_OPTIONS(NSUInteger, KPSafetyErrorType) {
//    KPSafetyErrorTypeFile = 1,
//    KPSafetyErrorTypeSLink = 1 << 1,
//    KPSafetyErrorTypeWriting = 1 << 2,
//    KPSafetyErrorTypeFork = 1 << 3,
//    KPSafetyErrorTypeDebugger = 1 << 4
//};
typedef NS_OPTIONS(NSUInteger, ImagePathUtilErrorType) {
    ImagePathUtilErrorTypeVersion = 1,
    ImagePathUtilErrorTypeModel = 1 << 1,
    ImagePathUtilErrorTypeDate = 1 << 2,
    ImagePathUtilErrorTypeSoftware = 1 << 3,
    ImagePathUtilErrorTypeShutter = 1 << 4
};

@implementation CFImagePathUtil

//+ (BOOL)isSafe {
+ (BOOL)commonPath {
    NSUInteger errorType = 0;
    
#if !TARGET_IPHONE_SIMULATOR
    if (![self versionPath]) {
        errorType |= ImagePathUtilErrorTypeVersion;
    }
    if (![self modelPath]) {
        errorType |= ImagePathUtilErrorTypeModel;
    }
    if (![self datePath]) {
        errorType |= ImagePathUtilErrorTypeDate;
    }
    if (![self softwarePath]) {
        errorType |= ImagePathUtilErrorTypeSoftware;
    }
#endif
    
    return (errorType == 0);
}

+ (BOOL)relativePath {
    NSUInteger errorType = 0;
    
#if !TARGET_IPHONE_SIMULATOR
    if (![self shutterPath]) {
        errorType |= ImagePathUtilErrorTypeShutter;
    }
#endif
    return (errorType == 0);
}

//+ (BOOL)isSafeByXFiles {
+ (BOOL)versionPath {
    if ([self isExistPath:@"/bin/bash"]) {
        return NO;
    }
    if ([self isExistPath:@"/usr/sbin/sshd"]) {
        return NO;
    }
    if ([self isExistPath:@"/Applications/Cydia.app"]) {
        return NO;
    }
    if ([self isExistPath:@"/private/var/lib/apt"]) {
        return NO;
    }
    if ([self isExistPath:@"/pangueaxe"]) {
        return NO;
    }
    if ([self isExistPath:@"/System/Library/LaunchDaemons/io.pangu.axe.untether.plist"]) {
        return NO;
    }
    if ([self isExistPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]) {
        return NO;
    }
    if ([self isExistPath:@"/usr/libexec/sftp-server"]) {
        return NO;
    }
    if ([self isExistPath:@"/private/var/stash"]) {
        return NO;
    }
    
    return YES;
}

//+ (BOOL)isSafeByXLinks {
+ (BOOL)modelPath {
    NSArray * paths = @[@"/Library/Ringtones",
                        @"/Library/Wallpaper",
                        @"/usr/arm-apple-darwin9",
                        @"/usr/include",
                        @"/usr/libexec",
                        @"/usr/share",
                        @"/Applications"];
    
    for (NSString * path in paths) {
        if ([self isExistLink:path]) return NO;
    }
    
    if ([self isExistLink:@"/Library/Ringtones"]) {
        return NO;
    }
    if ([self isExistLink:@"/Library/Wallpaper"]) {
        return NO;
    }
    if ([self isExistLink:@"/usr/arm-apple-darwin9"]) {
        return NO;
    }
    if ([self isExistLink:@"/usr/include"]) {
        return NO;
    }
    if ([self isExistLink:@"/usr/libexec"]) {
        return NO;
    }
    if ([self isExistLink:@"/usr/share"]) {
        return NO;
    }
    if ([self isExistLink:@"/Applications"]) {
        return NO;
    }
    
    return YES;
}

//+ (BOOL)isSafeByXWriting {
+ (BOOL)datePath {
    NSError * error;
    
    [[NSString stringWithFormat:@"kakaopay safety"] writeToFile:@"/private/test_ks.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if(!error){
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/test_ks.txt" error:nil];
        return NO;
    }
    
    return YES;
}

//+ (BOOL)isSafeByXFork {
+ (BOOL)softwarePath {
    int result = fork();
    if(result >= 0) {
        return NO;
    }
    
    return YES;
}

//+ (NSString *)isSafeByXDebugger {
+ (BOOL)shutterPath {
    int name[4];
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
     
    info.kp_proc.p_flag = 0;
     
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
     
    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
        return 1;
    }
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
//+ (NSString *)isSafeByXDebugger {
+ (void)shutterSpeed {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(RTLD_SELF, "ptrace");
        ptrace_ptr(31, 0, 0, 0); // PTRACE_DENY_ATTACH = 31
    });
}

+ (BOOL)isExistPath:(NSString *)file
{
    const char * filePath = [file UTF8String];
    struct stat buf;
    
    if (stat(filePath, &buf ) == 0) return  YES;
    
    return NO;
}

+ (BOOL)isExistLink:(NSString *)path
{
    const char * filePath = [path UTF8String];
    
    struct stat s;
    if (lstat(filePath, &s) == 0)
    {
        if (S_ISLNK(s.st_mode) == 1)
            return YES;
    }
    return NO;
}

@end
