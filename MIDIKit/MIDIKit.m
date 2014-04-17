//
//  MIDIKit.m
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"
#import <objc/runtime.h>
#import <TargetConditionals.h>
#import "MKPrivate.h"

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#import <dlfcn.h>
#endif

#ifdef DEBUG
BOOL MKSettingOSStatusEvaluationLogsOnError = YES;
#else
BOOL MKSettingOSStatusEvaluationLogsOnError = NO;
#endif

BOOL MKSettingDescriptionsIncludeProperties = NO;
BOOL MKSettingOSStatusEvaluationThrowsOnError = NO;

void MKInstallIntoContext(JSContext *c) {
    if(!c) return;

    for(Class cls in _MKExportedClasses()) {
        c[NSStringFromClass(cls)] = cls;
    }
    c[@"MIDIRestart"] = ^BOOL() { return [MKServer restart]; };
}

@implementation MIDIKit

#define GLOBAL(setter, getter, var) \
+ (BOOL)setter:(BOOL)val { var = val; return var; } \
+ (BOOL)getter { return var; }

GLOBAL(setDescriptionsIncludeProperties, descriptionsIncludeProperties, MKSettingDescriptionsIncludeProperties)
GLOBAL(setOSStatusEvaluationThrowsOnError, OSStatusEvaluationThrowsOnError, MKSettingOSStatusEvaluationThrowsOnError)
GLOBAL(setOSStatusEvaluationLogsOnError, OSStatusEvaluationLogsOnError, MKSettingOSStatusEvaluationLogsOnError)

- (instancetype)init {
    [NSException raise:@"MKMIDIKitInstantiationException" format:@"The MIDIKit object is not to be instantiated. Use its methods for manipulating MIDIKit options."];
    return nil;
}

+ (void)openGitHub {
    static NSString *_MKGitHubURL = @"http://github.com/JRHeaton/MIDIKit";

    // using objc_getClass() in case we're not linked.
    // REALLY don't want AppKit as a strict dependency :P
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    [[objc_getClass("UIApplication") sharedApplication] openURL:[NSURL URLWithString:_MKGitHubURL]];
#else
    Class _NSWorkspace = objc_getClass("NSWorkspace");
    if(!_NSWorkspace) {
        dlopen("/System/Library/Frameworks/AppKit.framework/AppKit", RTLD_LAZY);
    }
    [[objc_getClass("NSWorkspace") sharedWorkspace] openURL:[NSURL URLWithString:_MKGitHubURL]];
#endif
}

+ (OSStatus)evalOSStatus:(OSStatus)code name:(NSString *)name{
    if(code != 0) {
        if(MKSettingOSStatusEvaluationLogsOnError)
            NSLog(@"[MIDIKit Error] %@ : %@", name, [NSError errorWithDomain:NSOSStatusErrorDomain code:code userInfo:nil]);

        if(MKSettingOSStatusEvaluationThrowsOnError)
            [NSException raise:@"MKOSStatusEvaluationException" format:@"Error during operation: %@", name];
    }

    return code;
}

#undef GLOBAL

@end