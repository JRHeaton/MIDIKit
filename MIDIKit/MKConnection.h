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

// A connection object is essentially a convenient way to
// send and receive from multiple sources and destinations
// without having to constantly iterate through a container
// and reference ports.
//
// Usage:
// MKConnection *connection = [MKConnection connectionWithClient:myClient];
// [connection addDestination:myDestination];
// [connection sendMessage:[MKMessage controlChangeMessageWithController:0 value:0]];

@interface MKConnection : NSObject

// NOTE: instantiation with a client will automatically
// create an input and output port from the client
// if they're not already created.
+ (instancetype)connectionWithClient:(MKClient *)client;
- (instancetype)initWithClient:(MKClient *)client;

+ (instancetype)connectionWithInputPort:(MKInputPort *)inputPort outputPort:(MKOutputPort *)outputPort;
- (instancetype)initWithInputPort:(MKInputPort *)inputPort outputPort:(MKOutputPort *)outputPort;

- (void)addDestination:(MKEndpoint *)destination;
- (void)removeDestination:(MKEndpoint *)destination;
@property (nonatomic, readonly) NSMutableSet *destinations;

@property (nonatomic, readonly) MKInputPort *inputPort;
@property (nonatomic, readonly) MKOutputPort *outputPort;

// Uses the output port to send to all destinations
- (void)sendData:(NSData *)data;
- (void)sendMessage:(MKMessage *)message;
- (void)sendMessages:(MKMessage *)message, ... NS_REQUIRES_NIL_TERMINATION;

// Async helper
- (void)after:(NSTimeInterval)delay do:(void (^)(MKConnection *connection))block;

@end
