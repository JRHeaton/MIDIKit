//
//  MKOutputPort.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKOutputPort.h"

@implementation MKOutputPort

@synthesize client=_client;

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    if(!client.valid || !(self = [super init])) return nil;
    
    if(MIDIOutputPortCreate(client.MIDIRef, (__bridge CFStringRef)(name), &_MIDIRef) != 0)
        return nil;
    
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

- (void)dispose {
    MIDIPortDispose(self.MIDIRef);
    self.MIDIRef = 0;
}

- (void)sendData:(NSData *)data toDestination:(MKEndpoint *)endpoint {
    [self.sendQueue addOperationWithBlock:^{
        if(data.length <= 256) {
            MIDIPacketList list;
            list.numPackets = 1;
            list.packet[0].length = data.length;
            list.packet[0].timeStamp = 0;
            memcpy(list.packet[0].data, data.bytes, data.length);
            MIDISend(self.MIDIRef, endpoint.MIDIRef, &list);
        } else {
            [NSException raise:@"Data is too large" format:@"I am lazy and need to implement this."];
        }
    }];
}

- (void)sendMessage:(MKMessage *)msg toDestination:(MKEndpoint *)endpoint {
    [self sendData:msg.data toDestination:endpoint];
}

- (instancetype)sendJSArray:(JSValue *)dataArray toDestination:(MKEndpoint *)endpoint {
    NSArray *array = dataArray.toArray;
    NSMutableData *data = [NSMutableData dataWithLength:array.count];
    
    for(int i=0;i<array.count;++i) {
        ((UInt8 *)data.mutableBytes)[i] = [array[i] unsignedCharValue];
    }
    
    [self sendData:data toDestination:endpoint];
    
    return self;
}

@end
