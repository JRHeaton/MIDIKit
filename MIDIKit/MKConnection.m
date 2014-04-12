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
@synthesize client=_client;

@synthesize inputPort=_inputPort;
@synthesize outputPort=_outputPort;
@synthesize destinations=_destinations;

+ (instancetype)connectionWithClient:(MKClient *)client {
    return [[self alloc] initWithClient:(id)client];
}

- (instancetype)initWithInputPort:(MKInputPort *)inputPort outputPort:(MKOutputPort *)outputPort {
    if(!(self = [super init])) return nil;
    
    _inputPort = inputPort;
    _outputPort = outputPort;
    _destinations = [NSMutableArray arrayWithCapacity:0];
    
    return self;
}

+ (instancetype)connectionWithNewClient {
    return [self connectionWithClient:[MKClient new]];
}

+ (instancetype)connectionWithInputPort:(MKInputPort *)inputPort outputPort:(MKOutputPort *)outputPort {
    return [[self alloc] initWithInputPort:inputPort outputPort:outputPort];
}

- (instancetype)initWithClient:(MKClient *)client {
    self = [self initWithInputPort:client.firstInputPort outputPort:client.firstOutputPort];
    self.client = client;
    return self;
}

- (instancetype)addDestination:(MKEndpoint *)destination {
    if(![self.destinations containsObject:destination])
        [self.destinations addObject:destination];
    
    return self;
}

- (instancetype)removeDestination:(MKEndpoint *)destination {
    if([self.destinations containsObject:destination])
        [self.destinations removeObject:destination];
    
    return self;
}

- (MKEndpoint *)destinationAtIndex:(NSUInteger)index {
    return [_destinations objectAtIndex:index];
}

- (void)sendData:(NSData *)data {
    for(MKEndpoint *dst in self.destinations) {
        [self.outputPort sendData:data toDestination:dst];
    }
}

- (instancetype)sendNumberArray:(NSArray *)array {
    NSMutableData *data = [NSMutableData new];
    for(NSNumber *number in array) {
        if([number isKindOfClass:[NSNumber class]]) {
            unsigned char byte = number.unsignedCharValue;
            [data appendBytes:&byte length:1];
        }
    }
    
    [self sendData:data];
    
    return self;
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

- (void)sendMessageArray:(NSArray *)messages {
    for(MKMessage *msg in messages) {
        if([msg isKindOfClass:[MKMessage class]]) {
            [self sendMessage:msg];
        }
    }
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
