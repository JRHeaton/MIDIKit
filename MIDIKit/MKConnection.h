//
//  MKConnection.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKMessage.h"
#import "MKInputPort.h"
#import "MKOutputPort.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol MKConnectionJS <JSExport>

+ (instancetype)new;

JSExportAs(withClient,      + (instancetype)connectionWithClient:(MKClient *)client);
JSExportAs(send,            - (instancetype)sendByteValuesJS:(JSValue *)value);
JSExportAs(sendArray,       - (instancetype)sendNumberArray:(NSArray *)array);
JSExportAs(sendMessage,     - (instancetype)sendMessage:(MKMessage *)message);
JSExportAs(sendMessages,    - (instancetype)sendMessageArray:(NSArray *)messages);

@property (nonatomic, strong) MKClient *client;
@property (nonatomic, strong) MKInputPort *inputPort;
@property (nonatomic, strong) MKOutputPort *outputPort;

- (instancetype)addDestination:(MKDestination *)destination;
- (instancetype)addDestinations:(NSArray *)destinations;
- (instancetype)removeDestination:(MKDestination *)destination;
- (MKDestination *)destinationAtIndex:(NSUInteger)index;

@property (nonatomic, readonly) NSMutableArray *destinations;

@end


/**
 *  A connection object is essentially a convenient way to
 *  send and receive from multiple sources and destinations
 *  without having to constantly iterate through a container
 *  and reference ports.
 */
@interface MKConnection : NSObject <MKConnectionJS>

/**
 *  Creates a new connection with the given client.
 *
 *  @param client The client to use for creating the connection's objects,
 *         or nil to use the global client.
 *
 *  @return A new connection.
 */
- (instancetype)initWithClient:(MKClient *)client;

/**
 *  Sends data to all destinations, using the output port.
 *
 *  @param data The data to send.
 *
 *  @return self (for chaining).
 */
- (instancetype)sendData:(NSData *)data;


- (instancetype)sendMessages:(MKMessage *)message, ... NS_REQUIRES_NIL_TERMINATION;

@end
