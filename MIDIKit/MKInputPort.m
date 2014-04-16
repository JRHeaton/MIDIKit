//
//  MKInputPort.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"
#import "MKPrivate.h"

@interface MKInputPort ()
@property (nonatomic, strong) NSMutableArray *inputDelegates;
@end

@implementation MKInputPort

@dynamic name;

@synthesize client=_client;
@synthesize inputHandler=_inputHandler;
@synthesize inputHandlers=_inputHandlers;

static NSMapTable *_MKInputPortNameMap = nil;

static void _MKInputPortReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
    MKInputPort *self = (__bridge MKInputPort *)(readProcRefCon);
    MKSource *source = (__bridge MKSource *)(srcConnRefCon);

    MKDispatchSelectorToDelegates(@selector(inputPort:receivedPacketList:fromSource:), self.inputDelegates, @[ self, (__bridge id)pktlist, source ]);

    // parse out messages
    for(MKMessage *msg in [MKMessage messagesWithPacketList:(MIDIPacketList *)pktlist]) {
        MKDispatchSelectorToDelegates(@selector(inputPort:receivedMessage:fromSource:), self.inputDelegates, @[ self, msg, source ]);
    }

    MIDIPacket *packet = (MIDIPacket *)&pktlist->packet[0];
    for (int i=0;i<pktlist->numPackets;++i) {
        MKDispatchSelectorToDelegates(@selector(inputPort:receivedPacket:fromSource:), self.inputDelegates, @[ self, (__bridge id)packet, source ]);

        NSData *data = [NSData dataWithBytes:packet->data length:packet->length];
        MKDispatchSelectorToDelegates(@selector(inputPort:receivedData:fromSource:), self.inputDelegates, @[ self, data, source ]);

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
                ((MKInputHandler)inputHandler)(self, data ?: [NSData dataWithBytes:packet->data length:packet->length]);
            }
        }

        packet = MIDIPacketNext(packet);
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MKInputPortNameMap = [NSMapTable strongToWeakObjectsMapTable];
    });
}

+ (instancetype)inputPortWithName:(NSString *)name client:(MKClient *)client {
    return [[self alloc] initWithName:name client:client];
}

+ (instancetype)inputPortWithNameJS:(JSValue *)val client:(MKClient *)client {
    NSString *name = nil;
    if(!val.isUndefined && !val.isNull) {
        name = val.toString;
    }

    return [self inputPortWithName:name client:client];
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    if(!client) {
        client = [MKClient global];
    }
    if(!name) {
        name = [NSString stringWithFormat:@"%@-Input-%lu", client.name, (unsigned long)client.inputPorts.count];
    }

    MIDIPortRef p;
    MKInputPort *ret;

    if((ret = [_MKInputPortNameMap objectForKey:name]) != nil) return self = ret;
    if(!client.valid) return nil;
    if([MIDIKit evalOSStatus:MIDIInputPortCreate(client.MIDIRef, (__bridge CFStringRef)(name), _MKInputPortReadProc, (__bridge void *)(self), &p) name:@"Creating an input port"] != 0) {
        return nil;
    }

    if(!(self = [super initWithMIDIRef:p])) return nil;

    [_MKInputPortNameMap setObject:self forKey:name];
    
    self.client = client;
    [self.client.inputPorts addObject:self];

    self.inputHandlers = [NSMutableArray arrayWithCapacity:0];
    self.inputDelegates = [NSMutableArray arrayWithCapacity:0];
    
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

- (instancetype)addDelegate:(id<MKInputPortDelegate>)delegate {
    [_inputDelegates addObject:delegate];
    return self;
}

- (instancetype)removeDelegate:(id<MKInputPortDelegate>)delegate {
    [_inputDelegates removeObject:delegate];
    return self;
}

- (instancetype)removeAllDelegates {
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
