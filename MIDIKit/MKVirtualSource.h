//
//  MKVirtualSource.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKClient.h"

@protocol MKVirtualSourceJS <JSExport, MKObjectJS>

JSExportAs(withNameAndClient,   + (instancetype)virtualSourceWithNameJS:(JSValue *)val client:(MKClient *)client);

JSExportAs(receivedMessage,     - (instancetype)receivedMessage:(MKMessage *)message);
JSExportAs(receivedMessages,    - (instancetype)receivedMessages:(NSArray *)messages);

@end


// A virtual source is a client-created endpoint that
// is visible to other MIDI clients as a source that they can
// connect to an input port and receive data with, just as they
// would with a normal source.

@interface MKVirtualSource : MKObject <MKClientDependentInstaniation, MKVirtualSourceJS, MKEndpointProperties>

// Creates a new virtual source and adds it to the MIDI server
+ (instancetype)virtualSourceWithName:(NSString *)name client:(MKClient *)client;
- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

// Virtually sends data from this source.
- (instancetype)receivedData:(NSData *)data;
- (instancetype)receivedPacket:(MIDIPacket *)packet;
- (instancetype)receivedPacketList:(MIDIPacketList *)packetList;

@property (nonatomic, readonly) NSOperationQueue *receiveQueue;

@end
