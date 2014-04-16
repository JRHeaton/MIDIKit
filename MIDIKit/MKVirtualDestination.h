//
//  MKVirtualDestination.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKClient.h"

@protocol MKVirtualDestinationJS<JSExport, MKObjectJS>

JSExportAs(named, + (instancetype)virtualDestinationWithName:(NSString *)name client:(MKClient *)client);

@end


// A virtual destination is a client-created endpoint
// that is usable by other clients just like a normal destination.

@protocol MKVirtualDestinationDelegate;
@interface MKVirtualDestination : MKObject <MKClientDependentInstaniation, MKVirtualDestinationJS, MKEndpointProperties>

// Creates a new virtual destination and adds it to the MIDI server
- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

// Adds a new delegate to be notified when data is received
- (instancetype)addDelegate:(id<MKVirtualDestinationDelegate>)delegate;
- (instancetype)removeDelegate:(id<MKVirtualDestinationDelegate>)delegate;

@property (nonatomic, readonly) NSMutableArray *delegates;

@end


@protocol MKVirtualDestinationDelegate <NSObject>
@optional

// Called when a packet is received
- (void)virtualDestination:(MKVirtualDestination *)virtualDestination receivedData:(NSData *)data;
- (void)virtualDestination:(MKVirtualDestination *)virtualDestination receivedMessage:(MKMessage *)message;
- (void)virtualDestination:(MKVirtualDestination *)virtualDestination receivedPacket:(MIDIPacket *)packet;
- (void)virtualDestination:(MKVirtualDestination *)virtualDestination receivedPacketList:(MIDIPacketList *)packetList;

@end
