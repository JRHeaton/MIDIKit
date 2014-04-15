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

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

BOOL MKSettingDescriptionsIncludeProperties = NO;

NSArray *MKClassList() {
    static NSArray *_MKClassList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MKClassList = @[
                         [MIDIKit class],
                         [MKConnection class],
                         [MKMessage class],
                         [MKObject class],
                         [MKDevice class],
                         [MKClient class],
                         [MKInputPort class],
                         [MKOutputPort class],
                         [MKDestination class],
                         [MKSource class],
                         [MKVirtualDestination class],
                         [MKVirtualSource class]
                         ];
    });

    return _MKClassList;
}

void MKInstallIntoContext(JSContext *c) {
    if(!c) return;

    for(Class cls in MKClassList()) {
        c[NSStringFromClass(cls)] = cls;
    }
}

@implementation MIDIKit

#define GLOBAL(setter, getter, var) \
+ (BOOL)setter:(BOOL)val { var = val; return var; } \
+ (BOOL)getter { return var; }

GLOBAL(setDescriptionsIncludeProperties, descriptionsIncludeProperties, MKSettingDescriptionsIncludeProperties)

+ (void)openGitHub {
    static NSString *_MKGitHubURL = @"http://github.com/JRHeaton/MIDIKit";

    // using objc_getClass() in case we're not linked.
    // REALLY don't want AppKit as a strict dependency :P
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    [[objc_getClass("UIApplication") sharedApplication] openURL:[NSURL URLWithString:_MKGitHubURL]];
#else
    [[objc_getClass("NSWorkspace") sharedWorkspace] openURL:[NSURL URLWithString:_MKGitHubURL]];
#endif
}

+ (OSStatus)evalOSStatus:(OSStatus)code name:(NSString *)name throw:(BOOL)throw {
    if(code != 0) {
        NSLog(@"[MIDI Error] %@ : %@", name, [NSError errorWithDomain:NSOSStatusErrorDomain code:code userInfo:nil]);
        if(throw) {
            [NSException raise:@"MKOSStatusEvaluationException" format:@"Error during operation: %@", name];
        }
    }

    return code;
}

#undef GLOBAL

@end