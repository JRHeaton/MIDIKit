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

+ (BOOL)hasUniqueID {
    return YES;
}

- (MKDestination *)destinationAtIndex:(NSUInteger)index {
    return [[MKDestination alloc] initWithMIDIRef:MIDIEntityGetDestination(self.MIDIRef, index)];
}

- (MKSource *)sourceAtIndex:(NSUInteger)index {
    return [[MKSource alloc] initWithMIDIRef:MIDIEntityGetSource(self.MIDIRef, index)];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self destinationAtIndex:index];
}

- (MKDestination *)firstDestination {
    return [self destinationAtIndex:0];
}

- (MKSource *)firstSource {
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
