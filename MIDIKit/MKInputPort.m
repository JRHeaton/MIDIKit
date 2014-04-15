//
//  MKInputPort.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"

@interface MKInputPort ()
@property (nonatomic, strong) NSMutableSet *inputDelegates;
@end

@implementation MKInputPort

@synthesize client=_client;
@synthesize inputHandler=_inputHandler;
@synthesize inputHandlers=_inputHandlers;

static void _MKInputPortReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
    MKInputPort *self = (__bridge MKInputPort *)(readProcRefCon);
    MKSource *source = (__bridge MKSource *)(srcConnRefCon);

    MIDIPacket *packet = (MIDIPacket *)&pktlist->packet[0];
    for (int i=0;i<pktlist->numPackets;++i) {
        NSData *goodData = nil;

        for(id<MKInputPortDelegate> delegate in self.inputDelegates) {
            if([delegate respondsToSelector:@selector(inputPort:receivedData:fromSource:)]) {
                [delegate inputPort:self receivedData:(goodData = [NSData dataWithBytes:packet->data length:packet->length]) fromSource:source];
            }
        }

        if(self.inputHandler) {
            NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
            for(int i=0;i<pktlist->packet[0].length;++i) {
                [dataArray addObject:@(pktlist->packet[0].data[i])];
            }
            [self.inputHandler callWithArguments:@[dataArray]];
        }

        for(id inputHandler in self.inputHandlers) {
            if([inputHandler isKindOfClass:[JSValue class]]) {
                [inputHandler callWithArguments:@[ self, [MKMessage messageWithPacket:packet] ]];
            } else {
                ((MKInputHandler)inputHandler)(self, goodData ?: [NSData dataWithBytes:packet->data length:packet->length]);
            }
        }

        packet = MIDIPacketNext(packet);
    }
}

+ (instancetype)inputPortWithName:(NSString *)name client:(MKClient *)client {
    return [[self alloc] initWithName:name client:client];
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    MIDIPortRef p;

    if(!client.valid) return nil;
    if([MIDIKit evalOSStatus:MIDIInputPortCreate(client.MIDIRef, (__bridge CFStringRef)(name), _MKInputPortReadProc, (__bridge void *)(self), &p) name:@"Creating an input port"] != 0) {
        return nil;
    }

    if(!(self = [super initWithMIDIRef:p])) return nil;
    
    self.client = client;
    [self.client.inputPorts addObject:self];

    self.inputHandlers = [NSMutableArray arrayWithCapacity:0];
    self.inputDelegates = [NSMutableSet setWithCapacity:0];
    
    return self;
}

- (instancetype)connectSource:(MKSource *)source {
    [MIDIKit evalOSStatus:MIDIPortConnectSource(self.MIDIRef, source.MIDIRef, (__bridge_retained void *)(source)) name:@"Connect source"];
    return self;
}

- (instancetype)disconnectSource:(MKSource *)source {
    [MIDIKit evalOSStatus:MIDIPortDisconnectSource(self.MIDIRef, source.MIDIRef) name:@"Disconnect source"];
    return self;
}

- (instancetype)dispose {
    MIDIPortDispose(self.MIDIRef);
    self.MIDIRef = 0;
    return self;
}

- (instancetype)addInputDelegate:(id<MKInputPortDelegate>)delegate {
    [_inputDelegates addObject:delegate];
    return self;
}

- (instancetype)removeInputDelegate:(id<MKInputPortDelegate>)delegate {
    [_inputDelegates removeObject:delegate];
    return self;
}

- (instancetype)removeAllInputDelegates {
    [_inputDelegates removeAllObjects];
    return self;
}

- (instancetype)addInputHandler:(MKInputHandler)inputHandler {
    [self.inputHandlers addObject:inputHandler];
    return self;
}

- (instancetype)removeAllInputHandlers {
    [_inputHandlers removeAllObjects];
    return self;
}

- (instancetype)addInputHandlerJS:(JSValue *)handler {
    [self.inputHandlers addObject:handler];
    return self;
}

- (instancetype)removeInputHandlerJS:(JSValue *)handler {
    [self.inputHandlers removeObject:handler];
    return self;
}

- (instancetype)removeInputHandler:(MKInputHandler)inputHandler {
    [self.inputHandlers removeObject:inputHandler];
    return self;
}

@end
