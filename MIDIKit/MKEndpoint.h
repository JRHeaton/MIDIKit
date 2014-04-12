//
//  MKEndpoint.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

// Endpoints are either sources or destinations,
// which may be communicated to/from on input/output ports

@class MKEntity;
@protocol MKEndpointJS <JSExport>

+ (NSUInteger)numberOfSources;
+ (NSUInteger)numberOfDestinations;

+ (instancetype)firstOnlineDestinationNamed:(NSString *)name;
+ (instancetype)firstOnlineSourceNamed:(NSString *)name;

+ (instancetype)sourceAtIndex:(NSUInteger)index;
+ (instancetype)destinationAtIndex:(NSUInteger)index;

// Parent entity
- (MKEntity *)entity;

@end

@interface MKEndpoint : MKObject <MKEndpointJS>

+ (instancetype)firstDestinationMeetingCriteria:(BOOL (^)(MKEndpoint *candidate))block;
+ (instancetype)firstSourceMeetingCriteria:(BOOL (^)(MKEndpoint *candidate))block;

@end
