//
//  MKOutputPort.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKClient.h"

@class MKMessage;
@class MKDestination;
#pragma mark - -Mutual ObjC/JavaScript-

// Output ports are unidirectional ports through which you can
// transmit MIDI/MIDI-Sysex data to MIDI destination endpoints.

@protocol MKOutputPortJS <JSExport, MKObjectJS>

JSExportAs(named, + (instancetype)outputPortWithName:(NSString *)name client:(MKClient *)client);

#pragma mark - -Sending MIDI Data-

JSExportAs(send, - (instancetype)sendJS:(JSValue *)dataArray toDestination:(MKDestination *)destination);
JSExportAs(sendMessage, - (instancetype)sendMessage:(MKMessage *)msg toDestination:(MKDestination *)destination);
JSExportAs(sendMessages, - (instancetype)sendMessages:(NSArray *)messages toDestination:(MKDestination *)destination);

- (instancetype)dispose;

@end


#pragma mark - -Output Port Wrapper-
@interface MKOutputPort : MKObject <MKClientDependentInstaniation, MKOutputPortJS>

#pragma mark - -Init-
- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;


#pragma mark - -Sending Data-
// Sends the MIDI data to the given destination
- (instancetype)sendPacket:(MIDIPacket *)packet toDestination:(MKDestination *)destination;
- (instancetype)sendPacketList:(MIDIPacketList *)packetList toDestination:(MKDestination *)destination;
- (instancetype)sendData:(NSData *)data toDestination:(MKDestination *)destination;


#pragma mark - -Output Concurrency-
// This queue can be manipulated for various reasons.
// Example: [myOutputPort.sendQueue setMaxConcurrentOperationCount:1]
@property (nonatomic, readonly) NSOperationQueue *sendQueue;

@end
