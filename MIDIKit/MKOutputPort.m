//
//  MKOutputPort.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"
#import "MKPrivate.h"

@implementation MKOutputPort

@synthesize client=_client;

+ (instancetype)outputPortWithName:(NSString *)name client:(MKClient *)client {
    return [[self alloc] initWithName:name client:client];
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    if(!client.valid) return nil;
    if([MIDIKit evalOSStatus:MIDIOutputPortCreate(client.MIDIRef, (__bridge CFStringRef)(name), (void *)&_MIDIRef) name:@"Creating an output port"] != 0) {
        return nil;
    }

    self.client = client;
    [self.client.outputPorts addObject:self];
    
    return self;
}

- (NSOperationQueue *)sendQueue {
    static NSOperationQueue *queue = nil;
    if(!queue) {
        queue = [NSOperationQueue new];
    }
    
    return queue;
}

- (instancetype)dispose {
    MIDIPortDispose(self.MIDIRef);
    self.MIDIRef = 0;
    return self;
}

- (instancetype)sendJS:(JSValue *)dataArray toDestination:(MKDestination *)destination {
    NSArray *array = dataArray.toArray;
    NSMutableData *data = [NSMutableData dataWithLength:array.count];

    for(int i=0;i<array.count;++i) {
        ((UInt8 *)data.mutableBytes)[i] = [array[i] unsignedCharValue];
    }

    [self sendData:data toDestination:destination];

    return self;
}

- (instancetype)sendData:(NSData *)data toDestination:(MKDestination *)destination {
    [self.sendQueue addOperationWithBlock:^{
        MIDIPacketList *list = MKPacketListFromData(data);

        if(![MIDIKit evalOSStatus:MIDISend(self.MIDIRef, destination.MIDIRef, (const MIDIPacketList *)list) name:@"Send data"]) {
            // handle error
        }

        free(list);
    }];
    return self;
}

- (instancetype)sendMessage:(MKMessage *)msg toDestination:(MKDestination *)destination {
    return [self sendData:msg.data toDestination:destination];
}

- (instancetype)sendMessages:(NSArray *)messages toDestination:(MKDestination *)destination {
    for(MKMessage *msg in messages) {
        if([msg isKindOfClass:[MKMessage class]]) {
            (void)[self sendMessage:msg toDestination:destination];
        }
    }
    return self;
}

- (instancetype)sendPacket:(MIDIPacket *)packet toDestination:(MKDestination *)destination {
    NSParameterAssert(packet);

    // Must reallocate/copy because sending is done async on the sendQueue
    // and we can't give data on the stack
    MIDIPacketList *list = malloc(sizeof(MIDIPacketList));
    list->numPackets = 1;
    memcpy(&list->packet[0], packet, sizeof(MIDIPacket));

    id ret = [self sendPacketList:list toDestination:destination];
    free(list);

    return ret;
}

- (instancetype)sendPacketList:(MIDIPacketList *)packetList toDestination:(MKDestination *)destination {
    NSParameterAssert(packetList);
    NSParameterAssert(destination);
    if(!self.valid) return self; // TODO: handle this better

    [self.sendQueue addOperationWithBlock:^{
        if([MIDIKit evalOSStatus:MIDISend(self.MIDIRef, destination.MIDIRef, (const MIDIPacketList *)packetList) name:@"Send data"] != 0) {
            // TODO: handle error
        }
    }];

    return self;
}

@end
