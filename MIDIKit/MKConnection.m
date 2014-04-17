//
//  MKConnection.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"
#import "MKPrivate.h"

@implementation MKConnection {
    JSValue *_mirrorTransformJS;
}
@synthesize client=_client;

@synthesize inputPort=_inputPort;
@synthesize outputPort=_outputPort;
@synthesize destinations=_destinations;
@synthesize mirroring=_mirroring;
@synthesize mirrorTransform=_mirrorTransform;

+ (instancetype)connectionWithClient:(MKClient *)client {
    return [[self alloc] initWithClient:(id)client];
}

- (instancetype)initWithClient:(MKClient *)client {
    if(!(self = [super init])) return nil;

    _destinations = [NSMutableArray arrayWithCapacity:0];
    self.client = client ?: (client = [MKClient global]);

    return self;
}

- (instancetype)init {
    return [self initWithClient:[MKClient global]];
}

- (void)setClient:(MKClient *)client {
    _client = client;
    self.inputPort = client.firstInputPort;
    self.outputPort = client.firstOutputPort;
}

- (instancetype)addDestination:(MKDestination *)destination {
    if([destination isKindOfClass:[MKDestination class]])
        [self.destinations addObject:destination];
    
    return self;
}

- (instancetype)addDestinations:(NSArray *)destinations {
    for(MKDestination *d in destinations) {
        [self addDestination:d];
    }
    return self;
}

- (instancetype)removeDestination:(MKDestination *)destination {
    if([destination isKindOfClass:[MKDestination class]])
        [self.destinations removeObject:destination];
    
    return self;
}

- (MKDestination *)destinationAtIndex:(NSUInteger)index {
    return _destinations[index];
}

- (instancetype)sendData:(NSData *)data {
    for(MKDestination *dst in self.destinations) {
        if([dst isKindOfClass:[MKDestination class]])
            [self.outputPort sendData:data toDestination:dst];
    }
    return self;
}

- (instancetype)sendNumberArray:(NSArray *)array {
    return [self sendData:MKDataFromNumberArray(array)];
}

- (instancetype)sendByteValuesJS:(JSValue *)value {
    return [self sendData:MKDataFromNumberArray([JSContext currentArguments])];
}

- (instancetype)sendMessage:(MKMessage *)message {
    return [self sendData:message.data];
}

- (instancetype)sendMessages:(MKMessage *)message, ... {
    va_list args;
    va_start(args, message);
    for(MKMessage *msg = message;msg != nil;msg = va_arg(args, MKMessage *)) {
        [self sendMessage:msg];
    }
    va_end(args);
    return self;
}

- (instancetype)sendMessageArray:(NSArray *)messages {
    for(MKMessage *msg in messages) {
        if([msg isKindOfClass:[MKMessage class]]) {
            [self sendMessage:msg];
        }
    }
    return self;
}

- (void)setMirroring:(BOOL)mirroring {
    _mirroring = mirroring;

    if(!mirroring)
        [self.inputPort removeDelegate:self];
    else
        [self.inputPort addDelegate:self];
}

- (instancetype)setMirroringJS:(BOOL)mirroring {
    [self setMirroring:mirroring];
    return self;
}

- (instancetype)setMirrorTransformJS:(JSValue *)block {
    _mirrorTransformJS = block;
    self.mirrorTransform = nil;
    return self;
}

- (void)setMirrorTransform:(MKMessage *(^)(MKMessage *, MKSource *))mirrorTransform {
    _mirrorTransform = mirrorTransform;
    _mirrorTransformJS = nil;
}

- (void)inputPort:(MKInputPort *)inputPort receivedMessage:(MKMessage *)message fromSource:(MKSource *)source {
    if(self.mirroring) {
        if(_mirrorTransformJS)
            message = [_mirrorTransformJS callWithArguments:@[ message, source ]].toObject;
        else if(self.mirrorTransform)
            message = self.mirrorTransform(message, source);

        [self sendMessage:message];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ {\n\t"
                "inputPort    = %@, \n\t"
                "outputPort   = %@, \n\t"
                "client       = %@, \n\t"
                "destinations = %@}", super.description, self.inputPort, self.outputPort, self.client, self.destinations];
}

@end
