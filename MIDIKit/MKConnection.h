//
//  MKConnection.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKMessage.h"
#import "MKEndpoint.h"
#import "MKInputPort.h"
#import "MKOutputPort.h"
#import <JavaScriptCore/JavaScriptCore.h>

// A connection object is essentially a convenient way to
// send and receive from multiple sources and destinations
// without having to constantly iterate through a container
// and reference ports.
//
// Usage:
// MKConnection *connection = [MKConnection connectionWithClient:myClient];
// [connection addDestination:myDestination];
// [connection sendMessage:[MKMessage controlChangeMessageWithController:0 value:0]];

@protocol MKConnectionJS <JSExport>

+ (instancetype)connectionWithNewClient;
+ (instancetype)connectionWithClient:(MKClient *)client;

JSExportAs(connectionWithPorts,
+ (instancetype)connectionWithInputPort:(MKInputPort *)inputPort outputPort:(MKOutputPort *)outputPort);

JSExportAs(sendMessages,
- (void)sendMessageArray:(NSArray *)messages);
- (void)sendMessage:(MKMessage *)message;

JSExportAs(send, - (instancetype)sendNumberArray:(NSArray *)array);

@property (nonatomic, weak) MKClient *client;

@property (nonatomic, readonly) MKInputPort *inputPort;
@property (nonatomic, readonly) MKOutputPort *outputPort;

- (instancetype)addDestination:(MKEndpoint *)destination;
- (instancetype)removeDestination:(MKEndpoint *)destination;
- (MKEndpoint *)destinationAtIndex:(NSUInteger)index;
@property (nonatomic, readonly) NSMutableArray *destinations;

@end

@interface MKConnection : NSObject <MKConnectionJS>

// NOTE: instantiation with a client will automatically
// create an input and output port from the client
// if they're not already created.
- (instancetype)initWithClient:(MKClient *)client;
- (instancetype)initWithInputPort:(MKInputPort *)inputPort outputPort:(MKOutputPort *)outputPort;

// Async helper
- (instancetype)performBlock:(void (^)(MKConnection *c))block afterDelay:(NSTimeInterval)delay;

// Uses the output port to send to all destinations
- (void)sendData:(NSData *)data;
- (void)sendMessages:(MKMessage *)message, ... NS_REQUIRES_NIL_TERMINATION;

@end
