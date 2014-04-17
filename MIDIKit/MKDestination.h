//
//  MKDestination.h
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEnumerableObject.h"

@class MKOutputPort, MKMessage;
@protocol MKDestinationJS <JSExport, MKObjectJS, MKEnumerableObjectJS>

JSExportAs(sendMessage,     - (instancetype)sendMessage:(MKMessage *)msg usingOutputPort:(MKOutputPort *)outputPort);
JSExportAs(sendMessages,    - (instancetype)sendMessages:(NSArray *)messages usingOutputPort:(MKOutputPort *)outputPort);

@property (nonatomic, readonly) MKEntity *entity;

@end

@interface MKDestination : MKEnumerableObject <MKDestinationJS, MKEndpointProperties>

- (instancetype)sendPacket:(MIDIPacket *)packet usingOutputPort:(MKOutputPort *)outputPort;
- (instancetype)sendPacketList:(MIDIPacketList *)packetList usingOutputPort:(MKOutputPort *)outputPort;
- (instancetype)sendData:(NSData *)data usingOutputPort:(MKOutputPort *)outputPort;

@end
