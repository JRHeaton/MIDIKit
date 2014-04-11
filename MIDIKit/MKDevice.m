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

+ (NSUInteger)numberOfDevices {
    return MIDIGetNumberOfDevices();
}

+ (instancetype)firstDeviceMeetingCriteria:(BOOL (^)(MKDevice *candidate))block {
    for(NSInteger i=0;i<MIDIGetNumberOfDevices();++i) {
        MKDevice *candidate = [[MKDevice alloc] initWithMIDIRef:MIDIGetDevice(i)];
        if(block(candidate))
            return candidate;
    }
    
    return nil;
}

+ (instancetype)firstOnlineDeviceNamed:(NSString *)name {
    return [self firstDeviceMeetingCriteria:^BOOL(MKDevice *candidate) {
        return candidate.online && [candidate.name isEqualToString:name];
    }];
}

- (MKEndpoint *)rootDestination {
    return [[self entityAtIndex:0] destinationAtIndex:0];
}

- (MKEndpoint *)rootSource {
    return [[self entityAtIndex:0] sourceAtIndex:0];
}

- (MKEntity *)entityAtIndex:(NSUInteger)index {
    return [[MKEntity alloc] initWithMIDIRef:MIDIDeviceGetEntity(self.MIDIRef, index)];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self entityAtIndex:index];
}

- (MKEntity *)firstEntity {
    return [self entityAtIndex:0];
}

- (NSUInteger)numberOfEntities {
    return MIDIDeviceGetNumberOfEntities(self.MIDIRef);
}

- (NSArray *)entities {
    NSUInteger num = self.numberOfEntities;
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:num];
    for(NSUInteger i=0;i<num;++i) {
        [ret addObject:[self entityAtIndex:i]];
    }
    return ret.copy;
}

@end
