//
//  MKInputPort.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEntity.h"
#import "MKClient.h"

#pragma mark - -Mutual ObjC/JavaScript-

// Input ports are unidirectional ports through which
// you can receive input from MIDI source endpoints.

@protocol MKInputPortJS <JSExport, MKObjectJS>

JSExportAs(named, + (instancetype)inputPortWithName:(NSString *)name client:(MKClient *)client);

#pragma mark - -Connecting Sources-
// Calling this method will begin input from the given source
// to this input port, thus triggering the delegate callbacks
- (instancetype)connectSource:(MKSource *)source;
- (instancetype)disconnectSource:(MKSource *)source;


#pragma mark - -CoreMIDI Port Disposal-
// This disposes the underlying port
- (instancetype)dispose;


#pragma mark - -I/O-
JSExportAs(addInputHandler,
- (instancetype)addInputHandlerJS:(JSValue *)handler);
JSExportAs(removeInputHandler,
- (instancetype)removeInputHandlerJS:(JSValue *)handler);
- (instancetype)removeAllInputHandlers;

@property (nonatomic, strong) NSMutableArray *inputHandlers;


#pragma mark - -JavaScript ONLY input handler block-
@property (nonatomic, strong) JSValue *inputHandler;

@end


#pragma mark - -Input Port Wrapper-
@protocol MKInputPortDelegate;
@interface MKInputPort : MKObject <MKClientDependentInstaniation, MKInputPortJS>

#pragma mark - -Init-
- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;


#pragma mark - -Data Input-

#pragma mark Delegates
// Adds an input delegate who is interested in receiving
// input callbacks
- (instancetype)addInputDelegate:(id<MKInputPortDelegate>)delegate;
- (instancetype)removeInputDelegate:(id<MKInputPortDelegate>)delegate;
- (instancetype)removeAllInputDelegates;

#pragma mark Blocks
typedef void (^MKInputHandler)(MKInputPort *port, NSData *data);

- (instancetype)addInputHandler:(MKInputHandler)inputHandler;
- (instancetype)removeInputHandler:(MKInputHandler)inputHandler;

@end


#pragma mark - -Input Port Delegate-
@protocol MKInputPortDelegate <NSObject>

#pragma mark - -Data Input-
- (void)inputPort:(MKInputPort *)inputPort
     receivedData:(NSData *)data
       fromSource:(MKSource *)source;

@end