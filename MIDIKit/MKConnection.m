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

+ (instancetype)connectionWithNewClient {
    return [[self alloc] init];
}

- (instancetype)initWithClient:(MKClient *)client {
    if(!(self = [super init])) return nil;

    _destinations = [NSMutableArray arrayWithCapacity:0];
    self.client = client;
    self.inputPort = client.firstInputPort;
    self.outputPort = client.firstOutputPort;

    return self;
}

- (instancetype)init {
    return [self initWithClient:[MKClient new]];
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
    return _destinations[index];
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

- (instancetype)sendMessage:(MKMessage *)message {
    [self sendData:message.data];
    return self;
}

- (void)sendMessages:(MKMessage *)message, ... {
    va_list args;
    va_start(args, message);
    for(MKMessage *msg = message;msg != nil;msg = va_arg(args, MKMessage *)) {
        [self sendMessage:msg];
    }
    va_end(args);
}

- (instancetype)sendMessageArray:(NSArray *)messages {
    for(MKMessage *msg in messages) {
        if([msg isKindOfClass:[MKMessage class]]) {
            [self sendMessage:msg];
        }
    }
    return self;
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
