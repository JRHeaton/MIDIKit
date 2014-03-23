//
//  MKEntity.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKEndpoint.h"

// As described in MKDevice.h, an entity holds a set of endpoints
// This class is really not much more than a convenient way to access
// wrapper objects for entities(and then endpoints) to send data to.
// Indexed subscripting is supported on this class, and defaults to
// getting the DESTINATION at that index.

@interface MKEntity : MKObject

- (MKEndpoint *)destinationAtIndex:(NSUInteger)index;
- (MKEndpoint *)sourceAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index; // defaults to destination

- (MKEndpoint *)firstDestination;
- (MKEndpoint *)firstSource;

@property (nonatomic, readonly) NSArray *endpoints;

@end
