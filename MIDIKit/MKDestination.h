//
//  MKDestination.h
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

@class MKEntity;
@class MKOutputPort;
@class MKMessage;
@protocol MKDestinationJS <JSExport, MKObjectJS>

+ (NSUInteger)numberOfDestinations;
+ (NSUInteger)count; // shorthand

JSExportAs(atIndex,         + (instancetype)destinationAtIndex:(NSUInteger)index);

JSExportAs(firstNamed,      + (instancetype)firstDestinationNamed:(NSString *)name);
JSExportAs(firstContaining, + (instancetype)firstDestinationContaining:(NSString *)namePart);

JSExportAs(sendMessage,     - (instancetype)sendMessage:(MKMessage *)msg usingOutputPort:(MKOutputPort *)outputPort);
JSExportAs(sendMessages,    - (instancetype)sendMessages:(NSArray *)messages usingOutputPort:(MKOutputPort *)outputPort);

@property (nonatomic, readonly) MKEntity *entity;

@end

@interface MKDestination : MKObject <MKDestinationJS, MKEndpointProperties>

+ (instancetype)enumerateDestinations:(BOOL (^)(MKDestination *destination, NSUInteger index, BOOL *stop))block;
+ (instancetype)firstDestinationMeetingCriteria:(BOOL (^)(MKDestination *candidate))block;

- (instancetype)sendPacket:(MIDIPacket *)packet usingOutputPort:(MKOutputPort *)outputPort;
- (instancetype)sendPacketList:(MIDIPacketList *)packetList usingOutputPort:(MKOutputPort *)outputPort;
- (instancetype)sendData:(NSData *)data usingOutputPort:(MKOutputPort *)outputPort;

@end
