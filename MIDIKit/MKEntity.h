//
//  MKEntity.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKEndpoint.h"

// Entities represent a collection of endpoints on a device.
// In a typical simple setup, a device will have one entity,
// which contains one source and one destination. This is not
// required, though.

@class MKDevice;
@interface MKEntity : MKObject

- (NSUInteger)numberOfDestinations;
- (NSUInteger)numberOfSources;
- (MKEndpoint *)destinationAtIndex:(NSUInteger)index;
- (MKEndpoint *)sourceAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index; // defaults to destination

- (MKEndpoint *)firstDestination;
- (MKEndpoint *)firstSource;

- (MKDevice *)device;

@end
