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

@protocol MKDeviceJS <JSExport, MKObjectJS>

+ (NSUInteger)numberOfDevices;
+ (NSUInteger)count; // shorthand
JSExportAs(firstNamed, + (instancetype)firstDeviceNamed:(NSString *)name);
JSExportAs(firstContaining, + (instancetype)firstDeviceContaining:(NSString *)name);

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


@interface MKDevice : MKObject <MKDeviceJS, MKDeviceProperties>

// Convenient enumeration
+ (instancetype)firstDeviceMeetingCriteria:(BOOL (^)(MKDevice *candidate))block;

// Also available with subscripting. Ex: myDevice[2]
- (id)objectAtIndexedSubscript:(NSUInteger)index;

@end
