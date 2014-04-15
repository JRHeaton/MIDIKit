//
//  MKSource.m
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKSource.h"
#import "MKPrivate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
#pragma clang diagnostic ignored "-Wprotocol"

@implementation MKSource

+ (BOOL)hasUniqueID {
    return YES;
}

+ (NSUInteger)numberOfSources {
    return MIDIGetNumberOfSources();
}

+ (NSUInteger)count {
    return [self numberOfSources];
}

+ (instancetype)sourceAtIndex:(NSUInteger)index {
    return [self objectWithMIDIRef:MIDIGetSource(index)];
}

+ (instancetype)firstSourceMeetingCriteria:(BOOL (^)(MKSource *candidate))block {
    return [self enumerateSources:^BOOL(MKSource *endpoint, NSUInteger index, BOOL *stop) {
        return block(endpoint);
    }];
}

+ (instancetype)enumerateSources:(BOOL (^)(MKSource *endpoint, NSUInteger index, BOOL *stop))block {
    if(!block) return nil;

    BOOL stop = NO;
    for(NSInteger i=0;i<MIDIGetNumberOfSources() && !stop;++i) {
        id candidate = [[self alloc] initWithMIDIRef:MIDIGetSource(i)];
        if(block(candidate, i, &stop))
            return candidate;
    }

    return nil;
}

+ (instancetype)firstSourceContaining:(NSString *)namePart {
    return [self enumerateSources:^BOOL(MKSource *endpoint, NSUInteger index, BOOL *stop) {
        return endpoint.online && [endpoint.name rangeOfString:namePart].location != NSNotFound;
    }];
}

+ (instancetype)firstSourceNamed:(NSString *)name {
    return [self firstSourceMeetingCriteria:^BOOL(MKSource *candidate) {
        return candidate.online && [candidate.name isEqualToString:name];
    }];
}

- (MKEntity *)entity {
    return MKEntityForEndpoint(self);
}

@end

#pragma clang diagnostic pop