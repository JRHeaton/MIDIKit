//
//  MKDevice.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKEntity.h"

// A MIDI device owns one or more entities, which owns one or more endpoints.
// Endpoints are bidirectional.
// Example:
// + Device: 'Launchpad S'
// | + Entity 0: 'Launchpad S'
// | | - Endpoint 0: 'Launchpad S'
// This wrapper class provides areas of convenience when working with devices

@interface MKDevice : MKObject

// only valid if 'client' is set
- (void)sendData:(NSData *)data toEndpoint:(MKEndpoint *)endpoint;
- (void)sendDataArray:(NSArray *)array toEndpoint:(MKEndpoint *)endpoint;

- (MKEntity *)entityAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;

- (MKEntity *)firstEntity;
- (MKEndpoint *)rootEndpoint;

@property (nonatomic, readonly) NSArray *entities;

@end
