//
//  MKConnection.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKInputPort, MKOutputPort, MKClient, MKEndpoint;

@interface MKConnection : NSObject

+ (instancetype)connectionWithClient:(MKClient *)client;
- (instancetype)initWithInputPort:(MKInputPort *)inputPort outputPort:(MKOutputPort *)outputPort;
- (instancetype)initWithClient:(MKClient *)client;

- (void)addDestination:(MKEndpoint *)destination;
- (void)removeDestination:(MKEndpoint *)destination;
@property (nonatomic, readonly) NSMutableSet *destinations;

@property (nonatomic, readonly) MKInputPort *inputPort;
@property (nonatomic, readonly) MKOutputPort *outputPort;

- (void)sendData:(NSData *)data;

@end
