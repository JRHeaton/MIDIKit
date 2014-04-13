//
//  MKEntity.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEntity.h"
#import "MKDevice.h"

@implementation MKEntity

- (MKEndpoint *)destinationAtIndex:(NSUInteger)index {
    return [[MKEndpoint alloc] initWithMIDIRef:MIDIEntityGetDestination(self.MIDIRef, index)];
}

- (MKEndpoint *)sourceAtIndex:(NSUInteger)index {
    return [[MKEndpoint alloc] initWithMIDIRef:MIDIEntityGetSource(self.MIDIRef, index)];
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

- (NSUInteger)numberOfDestinations {
    return MIDIEntityGetNumberOfDestinations(self.MIDIRef);
}

- (NSUInteger)numberOfSources {
    return MIDIEntityGetNumberOfSources(self.MIDIRef);
}

- (MKDevice *)device {
    MIDIDeviceRef ret;
    if(!MIDIEntityGetDevice(self.MIDIRef, &ret))
        return [MKDevice objectWithMIDIRef:ret];
    
    return nil;
}

@end
