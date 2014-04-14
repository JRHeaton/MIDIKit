//
//  MIDIKit.m
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"

BOOL MKSettingDescriptionsIncludeProperties = NO;

void MKInstallIntoContext(JSContext *c) {
    if(!c) return;

    for(Class cls in @[
                       [MIDIKit class],
                       [MKConnection class],
                       [MKMessage class],
                       [MKObject class],
                       [MKClient class],
                       [MKInputPort class],
                       [MKOutputPort class],
                       [MKDestination class],
                       [MKSource class],
                       [MKEndpoint class],
                       [MKVirtualDestination class],
                       [MKVirtualSource class]
                       ]) {
        c[NSStringFromClass(cls)] = cls;
    }
}

@implementation MIDIKit

#define GLOBAL(setter, getter, var) \
+ (BOOL)setter:(BOOL)val { var = val; return var; } \
+ (BOOL)getter { return var; }

GLOBAL(setDescriptionsIncludeProperties, descriptionsIncludeProperties, MKSettingDescriptionsIncludeProperties)

#undef GLOBAL

@end