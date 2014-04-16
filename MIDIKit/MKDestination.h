//
//  MKDestination.h
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEnumerableObject.h"

@class MKEntity, MKOutputPort, MKMessage;
@protocol MKDestinationJS <JSExport, MKObjectJS, MKEnumerableObjectJS>

+ (NSUInteger)numberOfDestinations;
+ (NSUInteger)count; // shorthand
+ (NSArray *)all;
+ (NSArray *)allOnline;
+ (NSArray *)allOffline;

JSExportAs(atIndex,                 + (instancetype)destinationAtIndex:(NSUInteger)index);

JSExportAs(firstNamed,              + (instancetype)firstDestinationNamed:(NSString *)name);
JSExportAs(firstContaining,         + (instancetype)firstDestinationContaining:(NSString *)namePart);
JSExportAs(firstOnlineNamed,        + (instancetype)firstOnlineDestinationNamed:(NSString *)name);
JSExportAs(firstOnlineContaining,   + (instancetype)firstOnlineDestinationContaining:(NSString *)namePart);
JSExportAs(firstOfflineNamed,       + (instancetype)firstOfflineDestinationNamed:(NSString *)name);
JSExportAs(firstOfflineContaining,  + (instancetype)firstOfflineDestinationContaining:(NSString *)namePart);

JSExportAs(sendMessage,     - (instancetype)sendMessage:(MKMessage *)msg usingOutputPort:(MKOutputPort *)outputPort);
JSExportAs(sendMessages,    - (instancetype)sendMessages:(NSArray *)messages usingOutputPort:(MKOutputPort *)outputPort);

@property (nonatomic, readonly) MKEntity *entity;

@end

@interface MKDestination : MKEnumerableObject <MKDestinationJS, MKEndpointProperties>

- (instancetype)sendPacket:(MIDIPacket *)packet usingOutputPort:(MKOutputPort *)outputPort;
- (instancetype)sendPacketList:(MIDIPacketList *)packetList usingOutputPort:(MKOutputPort *)outputPort;
- (instancetype)sendData:(NSData *)data usingOutputPort:(MKOutputPort *)outputPort;

@end
