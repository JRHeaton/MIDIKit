//
//  MKPrivate.m
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKPrivate.h"
#import "MIDIKit.h"

MIDIPacketList *MKPacketListFromData(NSData *data) {
    NSData *self = data;

    MIDIPacketList *list = malloc(sizeof(MIDIPacketList) + self.length);

    if(!self.length) return list; // empty

#define MAX_PACKET_LEN 256

    NSUInteger remainder = self.length % MAX_PACKET_LEN;
    NSUInteger numPackets = (self.length - remainder) / MAX_PACKET_LEN;
    MIDIPacket *packet = MIDIPacketListInit(list);

    for(NSUInteger i=0;i<numPackets;++i) {
        packet = MIDIPacketListAdd(list, self.length, packet, 0, MAX_PACKET_LEN, &self.bytes[i * MAX_PACKET_LEN]);
    }
    if(remainder) {
        packet = MIDIPacketListAdd(list, sizeof(MIDIPacketList) + self.length, packet, 0, remainder, self.bytes);
    }

#undef  MAX_PACKET_LEN
    
    return list;
}

MKEntity *MKEntityForEndpoint(id endpoint) {
    MIDIEntityRef ret;
    if(![MIDIKit evalOSStatus:MIDIEndpointGetEntity(((MKObject *)endpoint).MIDIRef, &ret) name:@"Getting entity" throw:NO])
        return [[MKEntity alloc] initWithMIDIRef:ret];

    return nil;
}