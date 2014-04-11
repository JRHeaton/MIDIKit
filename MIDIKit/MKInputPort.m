//
//  MKInputPort.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKInputPort.h"
#import "MKClient.h"

@implementation MKInputPort

@synthesize client=_client;

static void _MKInputPortReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
    MKInputPort *self = (__bridge MKInputPort *)(readProcRefCon);
    MKEndpoint *source = (__bridge MKEndpoint *)(srcConnRefCon);
    
    if(self.inputHandler) {
        self.inputHandler(source, [NSData dataWithBytes:pktlist->packet[0].data length:pktlist->packet[0].length]);
    }
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    if(!client.valid || !(self = [super init])) return nil;
    
    if(MIDIInputPortCreate(client.MIDIRef, (__bridge CFStringRef)(name), _MKInputPortReadProc, (__bridge void *)(self), &_MIDIRef) != 0)
        return nil;
    
    self.client = client;
    [self.client.inputPorts addObject:self];
    
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

@end
