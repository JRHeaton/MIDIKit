//
//  MKEndpoint.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

@class MKEntity;
@interface MKEndpoint : MKObject

+ (instancetype)firstDestinationMeetingCriteria:(BOOL (^)(MKEndpoint *candidate))block;
+ (instancetype)firstSourceMeetingCriteria:(BOOL (^)(MKEndpoint *candidate))block;

- (MKEntity *)entity;

@end
