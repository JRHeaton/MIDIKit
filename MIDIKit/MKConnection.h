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

/// Creates a new connection with the global MKClient.
+ (instancetype)new;

JSExportAs(withClient,      + (instancetype)connectionWithClient:(MKClient *)client);
JSExportAs(send,            - (instancetype)sendByteValuesJS:(JSValue *)value);
JSExportAs(sendArray,       - (instancetype)sendNumberArray:(NSArray *)array);
JSExportAs(sendMessage,     - (instancetype)sendMessage:(MKMessage *)message);
JSExportAs(sendMessages,    - (instancetype)sendMessageArray:(NSArray *)messages);

@property (nonatomic, strong) MKClient *client;
@property (nonatomic, strong) MKInputPort *inputPort;
@property (nonatomic, strong) MKOutputPort *outputPort;

/**
 *  Adds a destination to the array of destinations for sending data to.
 *
 *  @param destination The destination to add.
 *
 *  @return self (for chaining).
 */
- (instancetype)addDestination:(MKDestination *)destination;

/**
 *  Adds multiple destinations to the array of destinations for sending data to.
 *
 *  @param destinations The destinations to add
 *
 *  @return self (for chaining).
 */
- (instancetype)addDestinations:(NSArray *)destinations;

/**
 *  Removes a destination from the array of destinations for sending data to.
 *
 *  @param destination The destination to be removed.
 *
 *  @return self (for chaining).
 */
- (instancetype)removeDestination:(MKDestination *)destination;

/**
 *  Returns the destination at a given index of the array of destinations for sending data to.
 *
 *  @param index The index of the desired destination.
 *
 *  @return The destination on success, nil on failure.
 */
- (MKDestination *)destinationAtIndex:(NSUInteger)index;

/// Returns all destinations.
@property (nonatomic, readonly) NSMutableArray *destinations;

@property (nonatomic, assign) BOOL mirroring;
JSExportAs(setMirroring, - (instancetype)setMirroringJS:(BOOL)mirroring);

JSExportAs(setMirrorTransform, - (instancetype)setMirrorTransformJS:(JSValue *)block);
@property (nonatomic, strong) MKMessage *(^mirrorTransform)(MKMessage *message, MKSource *source);

@end


/**
 *  A connection object is essentially a convenient way to
 *  send and receive from multiple sources and destinations
 *  without having to constantly iterate through a container
 *  and reference ports.
 */
@interface MKConnection : NSObject <MKConnectionJS, MKInputPortDelegate>

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
