//
//  MKObject.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

@implementation MKObject

static NSMutableDictionary *classMap = nil;

+ (void)registerClass:(Class)cls forCriteria:(BOOL (^)(MKObject *obj))block {
    if(!classMap) {
        classMap = [NSMutableDictionary dictionaryWithCapacity:0];
    }

    if([cls isSubclassOfClass:[self class]]) {
        classMap[NSStringFromClass(cls)] = block;
    }
}

- (id)initWithMIDIRef:(MIDIObjectRef)ref {
    MKObject *orig = [[self class] new];
    orig.MIDIRef = ref;

    for(NSString *key in classMap) {
        BOOL (^blk)(MKObject *obj) = classMap[key];

        Class candidiate = NSClassFromString(key);
        if([candidiate isSubclassOfClass:[self class]]) {
            if(blk(orig)) {
                MKObject *repl = [NSClassFromString(key) new];
                repl.MIDIRef = ref;
                return repl;
            }
        }
    }

    return orig;
}

+ (instancetype)objectWithMIDIRef:(MIDIObjectRef)ref {
    return [[self alloc] initWithMIDIRef:ref];
}

+ (instancetype)objectWithUniqueID:(MIDIUniqueID)uniqueID objectType:(MIDIObjectType *)objectType; {
    MKObject *ret = [self new];
    MIDIObjectRef obj;
    MIDIObjectFindByUniqueID(uniqueID, &obj, objectType);
    ret.MIDIRef = obj;
    return ret;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ valid=%@, properties=%@", [super description], self.valid ? @"YES" : @"NO", self.allProperties];
}

- (NSString *)stringForProperty:(CFStringRef)property {
    CFStringRef val;
    MIDIObjectGetStringProperty(self.MIDIRef, property, &val);
    return (__bridge_transfer NSString *)val;
}

- (NSInteger)integerForProperty:(CFStringRef)property {
    SInt32 val;
    MIDIObjectGetIntegerProperty(self.MIDIRef, property, &val);
    return (NSInteger)val;
}

- (NSData *)dataForProperty:(CFStringRef)property {
    CFDataRef val;
    MIDIObjectGetDataProperty(self.MIDIRef, property, &val);
    return (__bridge_transfer NSData *)val;
}

- (NSDictionary *)dictionaryForProperty:(CFStringRef)property {
    CFDictionaryRef val;
    MIDIObjectGetDictionaryProperty(self.MIDIRef, property, &val);
    return (__bridge_transfer NSDictionary *)val;
}

- (NSDictionary *)allProperties {
    CFPropertyListRef val;
    MIDIObjectGetProperties(self.MIDIRef, &val, true);
    return (__bridge_transfer NSDictionary *)val;
}

- (BOOL)isValid {
    return self.MIDIRef > 0;
}

- (NSString *)name {
    return [self stringForProperty:kMIDIPropertyName];
}

- (BOOL)isOnline {
    return ![self integerForProperty:kMIDIPropertyOffline];
}

@end
