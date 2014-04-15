//
//  MKDestination.h
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

@class MKEntity;
@protocol MKDestinationJS <JSExport>

+ (NSUInteger)numberOfDestinations;
+ (NSUInteger)count; // shorthand

JSExportAs(atIndex, + (instancetype)destinationAtIndex:(NSUInteger)index);

JSExportAs(firstNamed, + (instancetype)firstDestinationNamed:(NSString *)name);
JSExportAs(firstContaining, + (instancetype)firstDestinationContaining:(NSString *)namePart);

@property (nonatomic, readonly) MKEntity *entity;

@end

@interface MKDestination : MKObject <MKDestinationJS, MKEndpointProperties>

+ (instancetype)enumerateDestinations:(BOOL (^)(MKDestination *destination, NSUInteger index, BOOL *stop))block;
+ (instancetype)firstDestinationMeetingCriteria:(BOOL (^)(MKDestination *candidate))block;

@end
