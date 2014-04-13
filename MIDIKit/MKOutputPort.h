//
//  MKOutputPort.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKClient.h"

@class MKMessage;
@class MKEndpoint;
#pragma mark - -Mutual ObjC/JavaScript-

// Output ports are unidirectional ports through which you can
// transmit MIDI/MIDI-Sysex data to MIDI destination endpoints.

@protocol MKOutputPortJS <JSExport, MKObjectJS>

#pragma mark - -Sending MIDI Data-

#pragma mark Byte Array
JSExportAs(send,
- (instancetype)sendJSArray:(JSValue *)dataArray toDestination:(MKEndpoint *)endpoint);

#pragma mark Message
JSExportAs(sendMessage,
- (instancetype)sendMessage:(MKMessage *)msg toDestination:(MKEndpoint *)endpoint);

#pragma mark Message Array
JSExportAs(sendMessages, - (instancetype)sendMessageArray:(NSArray *)messages toDestination:(MKEndpoint *)endpoint);

#pragma mark Port Disposal
- (instancetype)dispose;

@end


#pragma mark - -Output Port Wrapper-
@interface MKOutputPort : MKObject <MKClientDependentInstaniation, MKOutputPortJS>

#pragma mark - -Init-
- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;


#pragma mark - -Sending Data-
// Sends the MIDI data to the given destination
- (void)sendData:(NSData *)data toDestination:(MKEndpoint *)endpoint;


#pragma mark - -Output Concurrency-
// This queue can be manipulated for various reasons.
// Example: [myOutputPort.sendQueue setMaxConcurrentOperationCount:1]
@property (nonatomic, readonly, strong) NSOperationQueue *sendQueue;

@end
