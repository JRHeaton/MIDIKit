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

+ (NSArray *)all {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateSources:^void(MKSource *source, NSUInteger index, BOOL *stop) {
        [ret addObject:source];
    }];

    return ret;
}

+ (instancetype)sourceAtIndex:(NSUInteger)index {
    return [self objectWithMIDIRef:MIDIGetSource(index)];
}

+ (void)enumerateSources:(void (^)(MKSource *endpoint, NSUInteger index, BOOL *stop))block {
    if(!block) return;

    BOOL stop = NO;
    for(NSInteger i=0;i<MIDIGetNumberOfSources() && !stop;++i) {
        id candidate = [[self alloc] initWithMIDIRef:MIDIGetSource(i)];
        block(candidate, i, &stop);
    }
}

+ (instancetype)firstSourceMeetingCriteria:(BOOL (^)(MKSource *candidate))block {
    __block MKSource *ret = nil;
    [self enumerateSources:^(MKSource *endpoint, NSUInteger index, BOOL *stop) {
        if(block(endpoint)) {
            ret = endpoint;
            *stop = YES;
        }
    }];

    return ret;
}

+ (instancetype)firstSourceContaining:(NSString *)namePart {
    __block MKSource *ret = nil;
    [self enumerateSources:^(MKSource *endpoint, NSUInteger index, BOOL *stop) {
        if(endpoint.online && [endpoint.name rangeOfString:namePart].location != NSNotFound) {
            ret = endpoint;
            *stop = YES;
        }
    }];
    return ret;
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