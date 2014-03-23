//
//  MKEntity.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEntity.h"

@implementation MKEntity

- (MKEndpoint *)destinationAtIndex:(NSUInteger)index {
    return [MKEndpoint objectWithMIDIRef:MIDIEntityGetDestination(self.MIDIRef, index)];
}

- (MKEndpoint *)sourceAtIndex:(NSUInteger)index {
    return [MKEndpoint objectWithMIDIRef:MIDIEntityGetSource(self.MIDIRef, index)];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self destinationAtIndex:index];
}

- (MKEndpoint *)firstDestination {
    return [self destinationAtIndex:0];
}

- (MKEndpoint *)firstSource {
    return [self sourceAtIndex:0];
}

@end
