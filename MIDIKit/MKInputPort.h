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

// Input ports are unidirectional ports through which
// you can receive input from MIDI source endpoints.

@protocol MKInputPortDelegate;
@interface MKInputPort : MKObject <MKClientDependentInstaniation> {
    NSMutableSet *_inputDelegates;
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

// Calling this method will begin input from the given source
// to this input port, thus triggering the delegate callbacks
- (void)connectSource:(MKEndpoint *)source;
- (void)disconnectSource:(MKEndpoint *)source;

// This disposes the underlying port
- (void)dispose;

// Adds an input delegate who is interested in receiving
// input callbacks
- (void)addInputDelegate:(id<MKInputPortDelegate>)delegate;
- (void)removeInputDelegate:(id<MKInputPortDelegate>)delegate;

@end

@protocol MKInputPortDelegate <NSObject>

- (void)inputPort:(MKInputPort *)inputPort
     receivedData:(NSData *)data
       fromSource:(MKEndpoint *)source;

@end