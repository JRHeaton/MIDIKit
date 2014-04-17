//
//  MKInputPort.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEntity.h"
#import "MKClient.h"

// Input ports are unidirectional ports through which
// you can receive input from MIDI source endpoints.

typedef void (^MKInputHandler)(MKInputPort *port, MKSource *source, NSData *data);
@protocol MKInputPortJS <JSExport, MKObjectJS>

JSExportAs(named, + (instancetype)inputPortWithNameJS:(JSValue *)val client:(MKClient *)client);

// Calling this method will begin input from the given source
// to this input port, thus triggering the delegate callbacks
- (instancetype)connectSource:(MKSource *)source;
- (instancetype)disconnectSource:(MKSource *)source;

// This disposes the underlying port
- (instancetype)dispose;

JSExportAs(addInputHandler,         - (instancetype)addInputHandlerJS:(JSValue *)handler);
JSExportAs(removeInputHandler,      - (instancetype)removeInputHandlerJS:(JSValue *)handler);
- (instancetype)removeAllInputHandlers;

@property (nonatomic, strong) NSMutableArray *inputHandlers;

@end


@protocol MKInputPortDelegate;
@interface MKInputPort : MKObject <MKClientDependentInstaniation, MKInputPortJS, MKPortProperties>

+ (instancetype)inputPortWithName:(NSString *)name client:(MKClient *)client;
- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

// Adds an input delegate who is interested in receiving
// input callbacks
- (instancetype)addDelegate:(id<MKInputPortDelegate>)delegate;
- (instancetype)removeDelegate:(id<MKInputPortDelegate>)delegate;
- (instancetype)removeAllDelegates;

- (instancetype)addInputHandler:(MKInputHandler)inputHandler;
- (instancetype)removeInputHandler:(MKInputHandler)inputHandler;

@end


@protocol MKInputPortDelegate <NSObject>
@optional

// IMPORTANT: this method will be called for all MKMessages in a MIDIPacketList on input
// It's using +messagesWithPacketList: to parse everything correctly. It's magic.
- (void)inputPort:(MKInputPort *)inputPort receivedMessage:(MKMessage *)message fromSource:(MKSource *)source;

// Raw data
- (void)inputPort:(MKInputPort *)inputPort receivedData:(NSData *)data fromSource:(MKSource *)source;
- (void)inputPort:(MKInputPort *)inputPort receivedPacket:(MIDIPacket *)packet fromSource:(MKSource *)source;
- (void)inputPort:(MKInputPort *)inputPort receivedPacketList:(MIDIPacketList *)packetList fromSource:(MKSource *)source;

@end