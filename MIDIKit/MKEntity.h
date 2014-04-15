//
//  MKEntity.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKSource.h"
#import "MKDestination.h"

#pragma mark - -Mutual ObjC/JavaScript-

// Entities represent a collection of endpoints on a device.
// In a typical simple setup, a device will have one entity,
// which contains one source and one destination. This is not
// required, though.

@class MKDevice;
@protocol MKEntityJS <JSExport, MKObjectJS>

#pragma mark - -Child Objects-
- (MKDestination *)firstDestination;
- (MKDestination *)firstSource;

- (NSUInteger)numberOfDestinations;
- (NSUInteger)numberOfSources;
- (MKDestination *)destinationAtIndex:(NSUInteger)index;
- (MKSource *)sourceAtIndex:(NSUInteger)index;


#pragma mark - -Parent Device-
- (MKDevice *)device;

@end


#pragma mark - -Entity Wrapper-
@interface MKEntity : MKObject <MKEntityJS>

#pragma mark - -Subscripting-
- (id)objectAtIndexedSubscript:(NSUInteger)index; // defaults to destination

@end
