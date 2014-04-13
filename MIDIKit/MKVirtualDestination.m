//
//  MKVirtualDestination.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKVirtualDestination.h"

@implementation MKVirtualDestination {
    NSMutableSet *_delegates;
}

@synthesize client=_client;

static void _MKVirtualDestinationReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
    MKVirtualDestination *self = (__bridge MKVirtualDestination *)(readProcRefCon);
    
    for(id<MKVirtualDestinationDelegate> delegate in self->_delegates) {
        if([delegate respondsToSelector:@selector(virtualDestination:receivedData:)]) {
            [delegate virtualDestination:self receivedData:[NSData dataWithBytes:pktlist->packet[0].data length:pktlist->packet[0].length]];
        }
    }
}

+ (instancetype)virtualDestinationWithName:(NSString *)name client:(MKClient *)client {
    return [[self alloc] initWithName:name client:client];
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    MIDIEndpointRef e;

    if(!client.valid) return nil;
    if(MIDIDestinationCreate(client.MIDIRef, (__bridge CFStringRef)(name), _MKVirtualDestinationReadProc, (__bridge void *)(self), &_MIDIRef) != 0)
        return nil;
    if(!(self = [super initWithMIDIRef:e])) return nil;
    
    self.client = client;
    [self.client.virtualDestinations addObject:self];
    _delegates = [NSMutableSet setWithCapacity:0];
    
    return self;
}

- (void)addDelegate:(id<MKVirtualDestinationDelegate>)delegate {
    if(![_delegates containsObject:delegate])
        [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<MKVirtualDestinationDelegate>)delegate {
    if([_delegates containsObject:delegate])
        [_delegates removeObject:delegate];
}

@end
