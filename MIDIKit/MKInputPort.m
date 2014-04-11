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

static void _MKInputPortReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
    MKInputPort *self = (__bridge MKInputPort *)(readProcRefCon);
    
    NSLog(@"Well it works");
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    if(!client.valid || !(self = [super init])) return nil;
    
    if(MIDIInputPortCreate(client.MIDIRef, (__bridge CFStringRef)(name), _MKInputPortReadProc, (__bridge void *)(self), &_MIDIRef) != 0)
        return nil;
    
    self.client = client;
    
    return self;
}

- (void)connectSource:(MKEndpoint *)source {
    MIDIPortConnectSource(self.MIDIRef, source.MIDIRef, (__bridge void *)(self));
}

- (void)disconnectSource:(MKEndpoint *)source {
    MIDIPortDisconnectSource(self.MIDIRef, source.MIDIRef);
}

- (void)dispose {
    MIDIPortDispose(self.MIDIRef);
    self.MIDIRef = 0;
}

@end
