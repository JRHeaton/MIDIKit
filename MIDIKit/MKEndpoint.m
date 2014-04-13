//
//  MKEndpoint.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEndpoint.h"
#import "MKEntity.h"

@implementation MKEndpoint

+ (NSUInteger)numberOfSources {
    return MIDIGetNumberOfSources();
}

+ (NSUInteger)numberOfDestinations {
    return MIDIGetNumberOfDestinations();
}

+ (instancetype)sourceAtIndex:(NSUInteger)index {
    return [MKEndpoint objectWithMIDIRef:MIDIGetSource(index)];
}

+ (instancetype)destinationAtIndex:(NSUInteger)index {
    return [MKEndpoint objectWithMIDIRef:MIDIGetDestination(index)];
}

+ (instancetype)firstDestinationMeetingCriteria:(BOOL (^)(MKEndpoint *candidate))block {
    for(NSInteger i=0;i<MIDIGetNumberOfDestinations();++i) {
        MKEndpoint *candidate = [[MKEndpoint alloc] initWithMIDIRef:MIDIGetDestination(i)];
        if(block(candidate))
            return candidate;
    }
    
    return nil;
}

+ (instancetype)firstSourceMeetingCriteria:(BOOL (^)(MKEndpoint *candidate))block {
    for(NSInteger i=0;i<MIDIGetNumberOfSources();++i) {
        MKEndpoint *candidate = [[MKEndpoint alloc] initWithMIDIRef:MIDIGetSource(i)];
        if(block(candidate))
            return candidate;
    }
    
    return nil;
}

+ (instancetype)firstOnlineDestinationNamed:(NSString *)name {
    return [self firstDestinationMeetingCriteria:^BOOL(MKEndpoint *candidate) {
        return candidate.online && [candidate.name isEqualToString:name];
    }];
}

+ (instancetype)firstOnlineSourceNamed:(NSString *)name {
    return [self firstSourceMeetingCriteria:^BOOL(MKEndpoint *candidate) {
        return candidate.online && [candidate.name isEqualToString:name];
    }];
}

- (MKEntity *)entity {
    MIDIEntityRef ret;
    if(!MIDIEndpointGetEntity(self.MIDIRef, &ret))
        return [[MKEntity alloc] initWithMIDIRef:ret];
    
    return nil;
}

@end
