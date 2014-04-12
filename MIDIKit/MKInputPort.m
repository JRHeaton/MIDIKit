//
//  MKInputPort.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKInputPort.h"
#import "MKClient.h"

@interface MKInputPort ()
@property (nonatomic, strong) NSMutableSet *inputDelegates;
@end

@implementation MKInputPort

@synthesize client=_client;
@synthesize inputHandler=_inputHandler;

static void _MKInputPortReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
    MKInputPort *self = (__bridge MKInputPort *)(readProcRefCon);
    MKEndpoint *source = (__bridge MKEndpoint *)(srcConnRefCon);
    
    for(id<MKInputPortDelegate> delegate in self.inputDelegates) {
        if([delegate respondsToSelector:@selector(inputPort:receivedData:fromSource:)]) {
            [delegate inputPort:self receivedData:[NSData dataWithBytes:pktlist->packet[0].data length:pktlist->packet[0].length] fromSource:source];
        }
    }
    
    if(self.inputHandler) {
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
        for(int i=0;i<pktlist->packet[0].length;++i) {
            [dataArray addObject:[NSNumber numberWithUnsignedChar:pktlist->packet[0].data[i]]];
        }
        [self.inputHandler callWithArguments:@[dataArray]];
    }
}

+ (instancetype)inputPortWithName:(NSString *)name client:(MKClient *)client {
    return [[self alloc] initWithName:name client:client];
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    if(!client.valid || !(self = [super init])) return nil;
    
    if(MIDIInputPortCreate(client.MIDIRef, (__bridge CFStringRef)(name), _MKInputPortReadProc, (__bridge void *)(self), &_MIDIRef) != 0)
        return nil;
    
    self.client = client;
    [self.client.inputPorts addObject:self];
    
    self.inputDelegates = [NSMutableSet setWithCapacity:0];
    
    return self;
}

- (void)connectSource:(MKEndpoint *)source {
    MIDIPortConnectSource(self.MIDIRef, source.MIDIRef, (__bridge_retained void *)(source));
}

- (void)disconnectSource:(MKEndpoint *)source {
    MIDIPortDisconnectSource(self.MIDIRef, source.MIDIRef);
}

- (void)dispose {
    MIDIPortDispose(self.MIDIRef);
    self.MIDIRef = 0;
}

- (void)addInputDelegate:(id<MKInputPortDelegate>)delegate {
    if(![_inputDelegates containsObject:delegate])
        [_inputDelegates addObject:delegate];
}

- (void)removeInputDelegate:(id<MKInputPortDelegate>)delegate {
    if([_inputDelegates containsObject:delegate])
        [_inputDelegates removeObject:delegate];
}

@end
