//
//  MKVirtualDestination.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"
#import "MKPrivate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
#pragma clang diagnostic ignored "-Wprotocol"

@implementation MKVirtualDestination

@synthesize client=_client;

static NSMapTable *_MKVirtualDestinationNameMap = nil;

static void _MKVirtualDestinationReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
    MKVirtualDestination *self = (__bridge MKVirtualDestination *)(readProcRefCon);

    MKDispatchSelectorToDelegates(@selector(virtualDestination:receivedPacketList:), self.delegates, @[ self, (__bridge id)pktlist ]);
    for(MKMessage *msg in [MKMessage messagesWithPacketList:(MIDIPacketList *)pktlist]) {
        MKDispatchSelectorToDelegates(@selector(virtualDestination:receivedMessage:), self.delegates, @[ self, msg ]);
    }

    MIDIPacket *packet = (MIDIPacket *)&pktlist->packet[0];
    for (int i=0;i<pktlist->numPackets;++i) {
        NSData *data = [NSData dataWithBytes:packet->data length:packet->length];
        MKDispatchSelectorToDelegates(@selector(virtualDestination:receivedData:), self.delegates, @[ self, data ]);

        packet = MIDIPacketNext(packet);
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MKVirtualDestinationNameMap = [NSMapTable strongToWeakObjectsMapTable];
    });
}

+ (BOOL)hasUniqueID {
    return YES;
}

+ (instancetype)virtualDestinationWithName:(NSString *)name client:(MKClient *)client {
    return [[self alloc] initWithName:name client:client];
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    if(!client) {
        client = [MKClient global];
    }
    
    MIDIEndpointRef e;
    MKVirtualDestination *ret;

    if((ret = [_MKVirtualDestinationNameMap objectForKey:name]) != nil) return self = ret;
    if(!client.valid) return nil;
    if([MIDIKit evalOSStatus:MIDIDestinationCreate(client.MIDIRef, (__bridge CFStringRef)(name), _MKVirtualDestinationReadProc, (__bridge void *)(self), (void *)&e) name:@"Creating a virtual destination"] != 0)
        return nil;
    if(!(self = [super initWithMIDIRef:e])) return nil;

    [_MKVirtualDestinationNameMap setObject:self forKey:name];
    
    self.client = client;
    [self.client.virtualDestinations addObject:self];
    _delegates = [NSMutableArray arrayWithCapacity:0];
    
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

#pragma clang diagnostic pop