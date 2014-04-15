//
//  MKDestination.m
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKDestination.h"
#import "MKPrivate.h"

@implementation MKDestination

+ (BOOL)hasUniqueID {
    return YES;
}

+ (NSUInteger)numberOfDestinations {
    return MIDIGetNumberOfDestinations();
}

+ (NSUInteger)count {
    return [self numberOfDestinations];
}

+ (instancetype)destinationAtIndex:(NSUInteger)index {
    return [self objectWithMIDIRef:MIDIGetDestination(index)];
}

+ (instancetype)firstDestinationMeetingCriteria:(BOOL (^)(MKDestination *candidate))block {
    return [self enumerateDestinations:^BOOL(MKDestination *endpoint, NSUInteger index, BOOL *stop) {
        return endpoint.online && block(endpoint);
    }];
}
+ (instancetype)enumerateDestinations:(BOOL (^)(MKDestination *endpoint, NSUInteger index, BOOL *stop))block {
    if(!block) return nil;

    BOOL stop = NO;
    for(NSInteger i=0;i<MIDIGetNumberOfDestinations() && !stop;++i) {
        id candidate = [[self alloc] initWithMIDIRef:MIDIGetDestination(i)];
        if(block(candidate, i, &stop))
            return candidate;
    }

    return nil;
}
+ (instancetype)firstDestinationContaining:(NSString *)namePart {
    return [self enumerateDestinations:^BOOL(MKDestination *endpoint, NSUInteger index, BOOL *stop) {
        return endpoint.online && [endpoint.name rangeOfString:namePart].location != NSNotFound;
    }];
}

+ (instancetype)firstDestinationNamed:(NSString *)name {
    return [self firstDestinationMeetingCriteria:^BOOL(MKDestination *candidate) {
        return candidate.online && [candidate.name isEqualToString:name];
    }];
}

- (MKEntity *)entity {
    return MKEntityForEndpoint(self);
}

@end
