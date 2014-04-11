//
//  MKEntity.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKEndpoint.h"

@interface MKEntity : MKObject

- (MKEndpoint *)destinationAtIndex:(NSUInteger)index;
- (MKEndpoint *)sourceAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index; // defaults to destination

- (MKEndpoint *)firstDestination;
- (MKEndpoint *)firstSource;

@property (nonatomic, readonly) NSArray *endpoints;

@end
