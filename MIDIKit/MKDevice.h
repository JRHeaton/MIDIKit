//
//  MKDevice.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKEntity.h"

@interface MKDevice : MKObject

- (MKEntity *)entityAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;

- (MKEntity *)firstEntity;
- (MKEndpoint *)rootDestination;
- (MKEndpoint *)rootSource;

@property (nonatomic, readonly) NSUInteger numberOfEntities;
@property (nonatomic, readonly) NSArray *entities;

@end
