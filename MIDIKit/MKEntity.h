//
//  MKEntity.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

// Entities represent a collection of endpoints on a device.
// In a typical simple setup, a device will have one entity,
// which contains one source and one destination. This is not
// required, though.

@class MKDevice, MKSource, MKDestination;
@protocol MKEntityJS <JSExport, MKObjectJS>

- (NSUInteger)numberOfDestinations;
- (NSUInteger)numberOfSources;
- (MKDestination *)destinationAtIndex:(NSUInteger)index;
- (MKSource *)sourceAtIndex:(NSUInteger)index;

@property (nonatomic, readonly) MKDevice *device;
@property (nonatomic, readonly) MKSource *firstSource;
@property (nonatomic, readonly) MKDestination *firstDestination;

@end


@interface MKEntity : MKObject <MKEntityJS, MKEntityProperties>

- (id)objectAtIndexedSubscript:(NSUInteger)index; // defaults to destination

@end
