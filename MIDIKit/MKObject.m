//
//  MKObject.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

@implementation MKObject

+ (instancetype)objectWithMIDIRef:(MIDIObjectRef)ref {
    MKObject *ret = [self new];
    ret.MIDIRef = ref;
    return ret;
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
