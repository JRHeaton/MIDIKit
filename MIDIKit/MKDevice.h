//
//  MKDevice.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEnumerableObject.h"
#import "MKEntity.h"

// Devices are parent objects of entities,
// and are usually the 'root' object created by the driver.

@protocol MKDeviceJS <JSExport, MKObjectJS, MKEnumerableObjectJS>

// Index-access to child entities
- (MKEntity *)entityAtIndex:(NSUInteger)index;

@property (nonatomic, readonly) NSUInteger numberOfEntities;

// This is dynamic, and will create all new wrappers (expensive)
@property (nonatomic, readonly) NSArray *entities;

// Zero-index objects
@property (nonatomic, readonly) MKEntity *firstEntity;
@property (nonatomic, readonly) MKDestination *rootDestination;
@property (nonatomic, readonly) MKSource *rootSource;

@end


@interface MKDevice : MKEnumerableObject <MKDeviceJS, MKDeviceProperties>

// returns an entity at index
- (id)objectAtIndexedSubscript:(NSUInteger)index;

@end
