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

#pragma mark - -Mutual ObjC/JavaScript-

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

#pragma mark - -Init-
+ (instancetype)new;
+ (instancetype)connectionWithNewClient;
+ (instancetype)connectionWithClient:(MKClient *)client;

#pragma mark - -Sending Data-
- (instancetype)sendMessageArray:(NSArray *)messages;
- (instancetype)sendMessage:(MKMessage *)message;

JSExportAs(send, - (instancetype)sendNumberArray:(NSArray *)array);


#pragma mark - -Coordinating Wrappers-
@property (nonatomic, weak) MKClient *client;
@property (nonatomic, strong) MKInputPort *inputPort;
@property (nonatomic, strong) MKOutputPort *outputPort;


#pragma mark - -Output Destinations-
- (instancetype)addDestination:(MKEndpoint *)destination;
- (instancetype)removeDestination:(MKEndpoint *)destination;
- (MKEndpoint *)destinationAtIndex:(NSUInteger)index;
@property (nonatomic, readonly) NSMutableArray *destinations;

@end


#pragma mark - -Connection Helper Class-
@interface MKConnection : NSObject <MKConnectionJS>

#pragma mark - -Init-
// NOTE: instantiation with a client will automatically
// create an input and output port from the client
// if they're not already created.
- (instancetype)initWithClient:(MKClient *)client;

#pragma mark - -Timed Block Execution Helpers-
// Async helper
- (instancetype)performBlock:(void (^)(MKConnection *c))block afterDelay:(NSTimeInterval)delay;


#pragma mark - -Sending Data-
// Uses the output port to send to all destinations
- (void)sendData:(NSData *)data;
- (void)sendMessages:(MKMessage *)message, ... NS_REQUIRES_NIL_TERMINATION;

@end
