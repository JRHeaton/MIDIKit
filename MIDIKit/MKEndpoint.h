//
//  MKEndpoint.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

#pragma mark - -Mutual ObjC/JavaScript-

// Endpoints are either sources or destinations,
// which may be communicated to/from on input/output ports

@class MKEntity;
@protocol MKEndpointJS <JSExport>

#pragma mark - -Enumeration/Init-
+ (NSUInteger)numberOfSources;
+ (NSUInteger)numberOfDestinations;
+ (instancetype)sourceAtIndex:(NSUInteger)index;
+ (instancetype)destinationAtIndex:(NSUInteger)index;

+ (instancetype)firstOnlineDestinationNamed:(NSString *)name;
+ (instancetype)firstOnlineSourceNamed:(NSString *)name;


#pragma mark - -Parent Entity-
- (MKEntity *)entity;

@end


#pragma mark - -Endpoint Wrapper-
@interface MKEndpoint : MKObject <MKEndpointJS, MKObjectJS>


#pragma mark - -Enumeration/Init-
+ (instancetype)firstDestinationMeetingCriteria:(BOOL (^)(MKEndpoint *candidate))block;
+ (instancetype)firstSourceMeetingCriteria:(BOOL (^)(MKEndpoint *candidate))block;

@end
