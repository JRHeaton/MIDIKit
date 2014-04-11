//
//  MKDevice.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKEntity.h"

// Devices are parent objects of entities,
// and are usually the 'root' object created by the driver.

@interface MKDevice : MKObject

// Convenient enumeration
+ (MKDevice *)firstDeviceMeetingCriteria:(BOOL (^)(MKDevice *candidate))block;

// Index-access to child entities
- (MKEntity *)entityAtIndex:(NSUInteger)index;
// Also available with subscripting. Ex: myDevice[2]
- (id)objectAtIndexedSubscript:(NSUInteger)index;

// Zero-index objects
- (MKEntity *)firstEntity;
- (MKEndpoint *)rootDestination;
- (MKEndpoint *)rootSource;

@property (nonatomic, readonly) NSUInteger numberOfEntities;

// This is dynamic, and will create all new wrappers (expensive)
@property (nonatomic, readonly) NSArray *entities;

@end
