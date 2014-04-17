//
//  MKEntity.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"


/**
 *  Entities represent a collection of endpoints on a device.
 *  In a typical simple setup, a device will have one entity,
 *  which contains one source and one destination. This is not
 *  required, though.
 */
@class MKDevice, MKSource, MKDestination;
@protocol MKEntityJS <JSExport, MKObjectJS>

- (MKDestination *)destinationAtIndex:(NSUInteger)index;
- (MKSource *)sourceAtIndex:(NSUInteger)index;

/// The owning/parent device.
@property (nonatomic, readonly) MKDevice *device;

/// The first source of the first entity of this device.
@property (nonatomic, readonly) MKSource *firstSource;

/// The first destination of the first entity of this device.
@property (nonatomic, readonly) MKDestination *firstDestination;

@property (nonatomic, readonly) NSUInteger numberOfDestinations;
@property (nonatomic, readonly) NSUInteger numberOfSources;

@end


@interface MKEntity : MKObject <MKEntityJS, MKEntityProperties>

- (id)objectAtIndexedSubscript:(NSUInteger)index; // defaults to destination

@end
