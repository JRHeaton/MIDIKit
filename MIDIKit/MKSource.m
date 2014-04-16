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

+ (NSUInteger)count {
    return MIDIGetNumberOfSources();
}

+ (instancetype)atIndex:(NSUInteger)index {
    return [self objectWithMIDIRef:MIDIGetSource(index)];
}

- (MKEntity *)entity {
    return MKEntityForEndpoint(self);
}

@end

#pragma clang diagnostic pop