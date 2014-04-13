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
    return [self enumerateDestinations:^BOOL(MKEndpoint *endpoint, NSUInteger index, BOOL *stop) {
        return block(endpoint);
    }];
}

+ (instancetype)firstSourceMeetingCriteria:(BOOL (^)(MKEndpoint *candidate))block {
    return [self enumerateSources:^BOOL(MKEndpoint *endpoint, NSUInteger index, BOOL *stop) {
        return block(endpoint);
    }];
}

+ (instancetype)enumerateDestinations:(MKEndpointEnumerationHandler)block {
    if(!block) return nil;

    BOOL stop = NO;
    for(NSInteger i=0;i<MIDIGetNumberOfDestinations() && !stop;++i) {
        MKEndpoint *candidate = [[MKEndpoint alloc] initWithMIDIRef:MIDIGetDestination(i)];
        if(block(candidate, i, &stop))
            return candidate;
    }

    return nil;
}

+ (instancetype)enumerateSources:(MKEndpointEnumerationHandler)block {
    if(!block) return nil;

    BOOL stop = NO;
    for(NSInteger i=0;i<MIDIGetNumberOfSources() && !stop;++i) {
        MKEndpoint *candidate = [[MKEndpoint alloc] initWithMIDIRef:MIDIGetSource(i)];
        if(block(candidate, i, &stop))
            return candidate;
    }

    return nil;
}

+ (instancetype)firstSourceContaining:(NSString *)namePart {
    return [self enumerateSources:^BOOL(MKEndpoint *endpoint, NSUInteger index, BOOL *stop) {
        return endpoint.online && [endpoint.name rangeOfString:namePart].location != NSNotFound;
    }];
}

+ (instancetype)firstDestinationContaining:(NSString *)namePart {
    return [self enumerateDestinations:^BOOL(MKEndpoint *endpoint, NSUInteger index, BOOL *stop) {
        return endpoint.online && [endpoint.name rangeOfString:namePart].location != NSNotFound;
    }];
}

+ (instancetype)firstDestinationNamed:(NSString *)name {
    return [self firstDestinationMeetingCriteria:^BOOL(MKEndpoint *candidate) {
        return candidate.online && [candidate.name isEqualToString:name];
    }];
}

+ (instancetype)firstSourceNamed:(NSString *)name {
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
