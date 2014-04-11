//
//  MKConnection.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKConnection.h"
#import "MKClient.h"
#import "MKInputPort.h"
#import "MKOutputPort.h"

@implementation MKConnection

+ (instancetype)connectionWithClient:(MKClient *)client {
    return [[self alloc] initWithClient:(id)client];
}

- (instancetype)initWithInputPort:(MKInputPort *)inputPort outputPort:(MKOutputPort *)outputPort {
    if(!(self = [super init])) return nil;
    
    _inputPort = inputPort;
    _outputPort = outputPort;
    _destinations = [NSMutableSet setWithCapacity:0];
    
    return self;
}

+ (instancetype)connectionWithInputPort:(MKInputPort *)inputPort outputPort:(MKOutputPort *)outputPort {
    return [[self alloc] initWithInputPort:inputPort outputPort:outputPort];
}

- (instancetype)initWithClient:(MKClient *)client {
    return [self initWithInputPort:client.firstInputPort outputPort:client.firstOutputPort];
}

- (void)addDestination:(MKEndpoint *)destination {
    if(![self.destinations containsObject:destination])
        [self.destinations addObject:destination];
}

- (void)removeDestination:(MKEndpoint *)destination {
    if([self.destinations containsObject:destination])
        [self.destinations removeObject:destination];
}

- (void)sendData:(NSData *)data {
    for(MKEndpoint *dst in self.destinations) {
        [self.outputPort sendData:data toDestination:dst];
    }
}

- (void)sendMessage:(MKMessage *)message {
    [self sendData:message.data];
}

- (void)sendMessages:(MKMessage *)message, ... {
    va_list args;
    va_start(args, message);
    for(MKMessage *msg = message;msg != nil;msg = va_arg(args, MKMessage *)) {
        [self sendMessage:msg];
    }
    va_end(args);
}

- (void)performBlock:(void (^)(MKConnection *connection))block {
    block(self);
}

- (instancetype)performBlock:(void (^)(MKConnection *c))block afterDelay:(NSTimeInterval)delay {
    if(block) {
        [self performSelector:@selector(performBlock:) withObject:[block copy] afterDelay:delay];
    }
    
    return self;
}

@end
