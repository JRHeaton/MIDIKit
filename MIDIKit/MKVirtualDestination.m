//
//  MKVirtualDestination.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"

@implementation MKVirtualDestination {
    NSMutableSet *_delegates;
}

@synthesize client=_client;

static void _MKVirtualDestinationReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
    MKVirtualDestination *self = (__bridge MKVirtualDestination *)(readProcRefCon);

    MIDIPacket *packet = (MIDIPacket *)&pktlist->packet[0];
    for (int i=0;i<pktlist->numPackets;++i) {
        NSData *goodData = nil;

        for(id<MKVirtualDestinationDelegate> delegate in self->_delegates) {
            if([delegate respondsToSelector:@selector(virtualDestination:receivedData:)]) {
                [delegate virtualDestination:self receivedData:(goodData = [NSData dataWithBytes:packet->data length:packet->length])];
            }
        }

        packet = MIDIPacketNext(packet);
    }
}

+ (BOOL)hasUniqueID {
    return YES;
}

+ (instancetype)virtualDestinationWithName:(NSString *)name client:(MKClient *)client {
    return [[self alloc] initWithName:name client:client];
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    MIDIEndpointRef e;

    if(!client.valid) return nil;
    if([MIDIKit evalOSStatus:MIDIDestinationCreate(client.MIDIRef, (__bridge CFStringRef)(name), _MKVirtualDestinationReadProc, (__bridge void *)(self), (void *)&_MIDIRef) name:@"Creating a virtual destination" throw:NO] != 0)
        return nil;
    if(!(self = [super initWithMIDIRef:e])) return nil;
    
    self.client = client;
    [self.client.virtualDestinations addObject:self];
    _delegates = [NSMutableSet setWithCapacity:0];
    
    return self;
}

- (instancetype)addDelegate:(id<MKVirtualDestinationDelegate>)delegate {
    [_delegates addObject:delegate];
    return self;
}

- (instancetype)removeDelegate:(id<MKVirtualDestinationDelegate>)delegate {
    [_delegates removeObject:delegate];
    return self;
}

@end
