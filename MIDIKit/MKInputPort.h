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

typedef void (^MKInputHandler)(MKInputPort *port, NSData *data);
@protocol MKInputPortJS <JSExport, MKObjectJS>

JSExportAs(named, + (instancetype)inputPortWithName:(NSString *)name client:(MKClient *)client);

// Calling this method will begin input from the given source
// to this input port, thus triggering the delegate callbacks
- (instancetype)connectSource:(MKSource *)source;
- (instancetype)disconnectSource:(MKSource *)source;

// This disposes the underlying port
- (instancetype)dispose;

JSExportAs(addInputHandler,
- (instancetype)addInputHandlerJS:(JSValue *)handler);
JSExportAs(removeInputHandler,
- (instancetype)removeInputHandlerJS:(JSValue *)handler);
- (instancetype)removeAllInputHandlers;

@property (nonatomic, strong) NSMutableArray *inputHandlers;

@property (nonatomic, strong) JSValue *inputHandler;

@end


@protocol MKInputPortDelegate;
@interface MKInputPort : MKObject <MKClientDependentInstaniation, MKInputPortJS>

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

// Adds an input delegate who is interested in receiving
// input callbacks
- (instancetype)addInputDelegate:(id<MKInputPortDelegate>)delegate;
- (instancetype)removeInputDelegate:(id<MKInputPortDelegate>)delegate;
- (instancetype)removeAllInputDelegates;

- (instancetype)addInputHandler:(MKInputHandler)inputHandler;
- (instancetype)removeInputHandler:(MKInputHandler)inputHandler;

@end


@protocol MKInputPortDelegate <NSObject>

- (void)inputPort:(MKInputPort *)inputPort
     receivedData:(NSData *)data
       fromSource:(MKSource *)source;

@end