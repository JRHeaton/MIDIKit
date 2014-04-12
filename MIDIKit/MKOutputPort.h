//
//  MKOutputPort.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKClient.h"
#import "MKMessage.h"

// Output ports are unidirectional ports through which you can
// transmit MIDI/MIDI-Sysex data to MIDI destination endpoints.

@protocol MKOutputPortJS <JSExport>

JSExportAs(send, - (instancetype)sendJSArray:(JSValue *)dataArray toDestination:(MKEndpoint *)endpoint);
- (void)dispose;

JSExportAs(sendMessage,
- (void)sendMessage:(MKMessage *)msg toDestination:(MKEndpoint *)endpoint);

JSExportAs(sendMessages, - (void)sendMessageArray:(NSArray *)messages toDestination:(MKEndpoint *)endpoint);

@end

@interface MKOutputPort : MKObject <MKClientDependentInstaniation, MKOutputPortJS, MKClientReference>

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

// Sends the MIDI data to the given destination
- (void)sendData:(NSData *)data toDestination:(MKEndpoint *)endpoint;

// This queue can be manipulated for various reasons.
// Example: [myOutputPort.sendQueue setMaxConcurrentOperationCount:1]
@property (nonatomic, readonly, strong) NSOperationQueue *sendQueue;

@end
