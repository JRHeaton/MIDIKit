//
//  MKDevice.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKDevice.h"
#import "MKClient.h"

@implementation MKDevice

static NSMutableDictionary *classMap = nil;

+ (void)registerClass:(Class)cls forCriteria:(BOOL (^)(MKObject *obj))block {
    if(!classMap) {
        classMap = [NSMutableDictionary dictionaryWithCapacity:0];
    }

    if([cls isSubclassOfClass:[self class]]) {
        classMap[NSStringFromClass(cls)] = block;
    }
}

+ (instancetype)objectWithMIDIRef:(MIDIObjectRef)ref {
    MKObject *orig = [super objectWithMIDIRef:ref];
    for(NSString *key in classMap) {
        BOOL (^blk)(MKObject *obj) = classMap[key];

        if(blk(orig)) {
            MKObject *repl = [NSClassFromString(key) new];
            repl.MIDIRef = ref;
            return (MKDevice *)repl;
        }
    }

    return (MKDevice *)orig;
}

- (void)sendData:(NSData *)data toEndpoint:(MKEndpoint *)endpoint {
    if(self.client) {
        [self.client sendData:data toEndpoint:endpoint];
    }
}

- (void)sendDataArray:(NSArray *)array toEndpoint:(MKEndpoint *)endpoint {
    if(self.client) {
        [self.client sendDataArray:array toEndpoint:endpoint];
    }
}

- (MKEndpoint *)rootEndpoint {
    return self[0][0];
}

- (MKEntity *)entityAtIndex:(NSUInteger)index {
    return [MKEntity objectWithMIDIRef:MIDIDeviceGetEntity(self.MIDIRef, index)];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self entityAtIndex:index];
}

- (MKEntity *)firstEntity {
    return [self entityAtIndex:0];
}

@end
