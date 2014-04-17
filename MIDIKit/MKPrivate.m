//
//  MKPrivate.m
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKPrivate.h"
#import "MIDIKit.h"

NSArray *_MKExportedClasses() {
    static NSArray *ret;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ret = @[
                [MIDIKit class],
                [MKConnection class],
                [MKMessage class],
                [MKObject class],
                [MKDevice class],
                [MKClient class],
                [MKInputPort class],
                [MKOutputPort class],
                [MKDestination class],
                [MKSource class],
                [MKEntity class],
                [MKVirtualDestination class],
                [MKVirtualSource class],
                [MKServer class]
                ];
    });

    return ret;
}

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
        MIDIPacketListAdd(list, sizeof(MIDIPacketList) + self.length, packet, 0, remainder, self.bytes);
    }

#undef  MAX_PACKET_LEN
    
    return list;
}

MKEntity *MKEntityForEndpoint(id endpoint) {
    MIDIEntityRef ret;
    if(![MIDIKit evalOSStatus:MIDIEndpointGetEntity(((MKObject *)endpoint).MIDIRef, &ret) name:@"Getting entity"])
        return [[MKEntity alloc] initWithMIDIRef:ret];

    return nil;
}

void MKDispatchSelectorToDelegates(SEL selector, NSArray *delegates, NSArray *arguments) {
    if(!delegates.count) return;

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[delegates.firstObject methodSignatureForSelector:selector]];
    [invocation setSelector:selector];

    for(NSUInteger i=0;i<arguments.count;++i) {
        __unsafe_unretained id val = arguments[i];
        [invocation setArgument:&val atIndex:i + 2];
    }

    for(id delegate in delegates) {
        if([delegate respondsToSelector:selector]) {
            [invocation invokeWithTarget:delegate];
        }
    }
}

NSData *MKDataFromNumberArray(NSArray *array) {
    NSMutableData *ret = [NSMutableData dataWithLength:array.count];
    for(id num in array) {
        UInt8 byte = [([num isKindOfClass:[JSValue class]] ? [num toNumber] : num) unsignedCharValue];
        [ret appendBytes:&byte length:1];
    }
    return ret;
}

Class _MKClassForType(MIDIObjectType type, NSString **objectTypeName) {
    Class c;
    NSString *n;
    switch(type & ~kMIDIObjectType_ExternalMask) {
        case kMIDIObjectType_Device:        c = [MKDevice class];       n = @"device"; break;
        case kMIDIObjectType_Destination:   c = [MKDestination class];  n = @"destination"; break;
        case kMIDIObjectType_Source:        c = [MKSource class];       n = @"source"; break;
        case kMIDIObjectType_Entity:        c = [MKEntity class];       n = @"entity"; break;
        default:                            c = [MKObject class];       n = @"object"; break;
    }
    if(objectTypeName) {
        *objectTypeName = n.copy;
    }

    return c;
}