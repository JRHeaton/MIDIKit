//
//  MKDestination.m
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"
#import "MKPrivate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
#pragma clang diagnostic ignored "-Wprotocol"

@implementation MKDestination

@dynamic name;

+ (BOOL)hasUniqueID {
    return YES;
}

+ (NSUInteger)count {
    return MIDIGetNumberOfDestinations();
}

+ (instancetype)atIndex:(NSUInteger)index {
    if(index >= [self count]) {
        static NSString *exceptionName = @"MKEnumerableObjectRangeException";
        static NSString *format = @"+atIndex called with index (%lu) higher than what is available. Please use this responsibly in hand with +count";

        if([JSContext currentContext]) {
            NSLog(format, index);
        } else {
            [NSException raise:exceptionName format:format, index];
        }

        return nil;
    }

    return [self objectWithMIDIRef:MIDIGetDestination(index)];
}

- (MKEntity *)entity {
    return MKEntityForEndpoint(self);
}

- (instancetype)sendPacket:(MIDIPacket *)packet usingOutputPort:(MKOutputPort *)outputPort {
    [outputPort sendPacket:packet toDestination:self];
    return self;
}

- (instancetype)sendPacketList:(MIDIPacketList *)packetList usingOutputPort:(MKOutputPort *)outputPort {
    [outputPort sendPacketList:packetList toDestination:self];
    return self;
}

- (instancetype)sendData:(NSData *)data usingOutputPort:(MKOutputPort *)outputPort {
    [outputPort sendData:data toDestination:self];
    return self;
}

- (instancetype)sendMessage:(MKMessage *)msg usingOutputPort:(MKOutputPort *)outputPort {
    [outputPort sendMessage:msg toDestination:self];
    return self;
}

- (instancetype)sendMessages:(NSArray *)messages usingOutputPort:(MKOutputPort *)outputPort {
    [outputPort sendMessages:messages toDestination:self];
    return self;
}

@end

#pragma clang diagnostic pop