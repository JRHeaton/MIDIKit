//
//  MKInputPort.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKEntity.h"
#import "MKClient.h"

#pragma mark - -Mutual ObjC/JavaScript-

// Input ports are unidirectional ports through which
// you can receive input from MIDI source endpoints.

@protocol MKInputPortJS <JSExport>

#pragma mark - -Connecting Sources-
// Calling this method will begin input from the given source
// to this input port, thus triggering the delegate callbacks
- (void)connectSource:(MKEndpoint *)source;
- (void)disconnectSource:(MKEndpoint *)source;


#pragma mark - -CoreMIDI Port Disposal-
// This disposes the underlying port
- (void)dispose;


#pragma mark - -JavaScript ONLY input handler block-
@property (nonatomic, strong) JSValue *inputHandler;

@end


#pragma mark - -Input Port Wrapper-
@protocol MKInputPortDelegate;
@interface MKInputPort : MKObject <MKClientDependentInstaniation, MKInputPortJS, MKClientReference, MKObjectJS> {
    NSMutableSet *_inputDelegates;
}

#pragma mark - -Init-
+ (instancetype)inputPortWithName:(NSString *)name client:(MKClient *)client;
- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;


#pragma mark - -Data Input Delegates-
// Adds an input delegate who is interested in receiving
// input callbacks
- (void)addInputDelegate:(id<MKInputPortDelegate>)delegate;
- (void)removeInputDelegate:(id<MKInputPortDelegate>)delegate;

@end


#pragma mark - -Input Port Delegate-
@protocol MKInputPortDelegate <NSObject>

#pragma mark - -Data Input-
- (void)inputPort:(MKInputPort *)inputPort
     receivedData:(NSData *)data
       fromSource:(MKEndpoint *)source;

@end