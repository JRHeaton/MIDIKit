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


@implementation MIDIKit

#define GLOBAL(setter, getter, var) \
+ (BOOL)setter:(BOOL)val { var = val; return var; } \
+ (BOOL)getter { return var; }

GLOBAL(setDescriptionsIncludeProperties, descriptionsIncludeProperties, MKSettingDescriptionsIncludeProperties)
GLOBAL(setOSStatusEvaluationThrowsOnError, OSStatusEvaluationThrowsOnError, MKSettingOSStatusEvaluationThrowsOnError)
GLOBAL(setOSStatusEvaluationLogsOnError, OSStatusEvaluationLogsOnError, MKSettingOSStatusEvaluationLogsOnError)

- (instancetype)init {
    [NSException raise:@"MKInstantiationException" format:@"You cannot init this class. Use its class methods for manipulating MIDIKit options."];
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
        if(dlopen("/System/Library/Frameworks/AppKit.framework/AppKit", RTLD_LAZY))
            [[objc_getClass("NSWorkspace") sharedWorkspace] openURL:[NSURL URLWithString:_MKGitHubURL]];
        else
            NSLog(@"Could not load AppKit. Therefore, I cannot take you to the browser. Frowny pants.");
    }
#endif
}

+ (OSStatus)evalOSStatus:(OSStatus)code name:(NSString *)name{
    if(code != 0) {
        if(MKSettingOSStatusEvaluationLogsOnError)
            NSLog(@"[MIDIKit Error] %@ : %@", name, [NSError errorWithDomain:NSOSStatusErrorDomain code:code userInfo:nil]);

        if(MKSettingOSStatusEvaluationThrowsOnError) {
            if([JSContext currentContext]) {
                [[JSContext currentContext] evaluateScript:[NSString stringWithFormat:@"throw new Error(%@)", name]];
            }
            else
                [NSException raise:@"MKOSStatusEvaluationException" format:@"Error during operation: %@", name];
        }
    }

    return code;
}

+ (void)installIntoContext:(JSContext *)c {
    if(!c) return;

    for(Class cls in _MKExportedClasses()) {
        c[NSStringFromClass(cls)] = cls;
    }
    c[@"MIDIRestart"] = ^BOOL() { return [MKServer restart]; };
}

#undef GLOBAL

@end