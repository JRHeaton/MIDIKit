//
//  MKDevice.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKDevice.h"
#import "MKClient.h"

@implementation MKDevice

- (void)sendData:(NSData *)data toEndpoint:(MKEndpoint *)endpoint {
    if(self.client) {
        [self.client sendData:data toEndpoint:endpoint];
    }
}

- (void)sendDataArray:(NSArray *)array toEndpoint:(MKEndpoint *)endpoint {
    if(self.client) {
        [self.client sendDataArray:array toEndpoint:endpoint];
    }
}

- (MKEndpoint *)rootEndpoint {
    MKEntity *entity = self[0];

    return entity[0];
}

- (MKEntity *)entityAtIndex:(NSUInteger)index {
    return [MKEntity objectWithMIDIRef:MIDIDeviceGetEntity(self.MIDIRef, index)];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self entityAtIndex:index];
}

- (MKEntity *)firstEntity {
    return [self entityAtIndex:0];
}

- (NSUInteger)numberOfEntities {
    return MIDIDeviceGetNumberOfEntities(self.MIDIRef);
}

- (NSArray *)entities {
    NSUInteger num = self.numberOfEntities;
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:num];
    for(NSUInteger i=0;i<num;++i) {
        [ret addObject:[self entityAtIndex:i]];
    }
    return ret.copy;
}

@end
