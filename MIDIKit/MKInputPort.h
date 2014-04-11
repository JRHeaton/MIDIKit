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

@protocol MKInputPortDelegate;
@interface MKInputPort : MKObject <MKClientDependentInstaniation> {
    NSMutableSet *_inputDelegates;
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

- (void)connectSource:(MKEndpoint *)source;
- (void)disconnectSource:(MKEndpoint *)source;

- (void)dispose;

- (void)addInputDelegate:(id<MKInputPortDelegate>)delegate;
- (void)removeInputDelegate:(id<MKInputPortDelegate>)delegate;

@end

@protocol MKInputPortDelegate <NSObject>

- (void)inputPort:(MKInputPort *)inputPort
     receivedData:(NSData *)data
       fromSource:(MKEndpoint *)source;

@end