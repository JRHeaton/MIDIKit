//
//  MKMessage.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKMessage.h"

@interface MKMessage ()
@property (nonatomic, readonly) NSMutableData *mutableData;
@end

@implementation MKMessage

@synthesize type=_type;
@synthesize keyOrController=_keyOrController;
@synthesize velocityOrValue=_velocityOrValue;
@synthesize channel=_channel;

+ (instancetype)controlChangeMessageWithController:(UInt8)controller value:(UInt8)value {
    static UInt8 buf[3] = { 0xb0, 0x00, 0x00 };
    buf[1] = controller;
    buf[2] = value;
    
    return [[self alloc] initWithData:[NSData dataWithBytes:buf length:3]];
}

+ (instancetype)messageWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

+ (instancetype)messageWithPacket:(MIDIPacket *)packet {
    return [[self alloc] initWithPacket:packet];
}

- (instancetype)initWithData:(NSData *)data {
    if(!(self = [super init])) return nil;
    _mutableData = data.mutableCopy ?: [NSMutableData dataWithCapacity:0];
    return self;
}

- (instancetype)init {
    if(!(self = [super init])) return nil;
    _mutableData = [NSMutableData dataWithCapacity:0];
    return self;
}

- (instancetype)initWithPacket:(MIDIPacket *)packet {
    if(!(self = [self init])) return nil;
    
    [self.mutableData setLength:packet->length];
    memcpy(self.bytes, packet->data, packet->length);
    
    return self;
}

+ (instancetype)messageWithType:(MKMessageType)type keyOrController:(UInt8)keyOrController velocityOrValue:(UInt8)velocityOrValue {
    return [[self alloc] initWithType:type keyOrController:keyOrController velocityOrValue:velocityOrValue];
}

+ (instancetype):(UInt8)type :(UInt8)keyOrController :(UInt8)velocityOrValue {
    return [[self alloc] initWithType:type keyOrController:keyOrController velocityOrValue:velocityOrValue];
}

- (instancetype)initWithType:(MKMessageType)type
             keyOrController:(UInt8)keyOrController
             velocityOrValue:(UInt8)velocityOrValue {
    UInt8 buf[3] = { type, keyOrController, velocityOrValue };

    return [self initWithData:[NSData dataWithBytes:buf length:3]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ length=0x%lx, type=0x%02x, keyOrController=0x%02x, velocityOrValue=0x%02x, channel=%d", super.description, (unsigned long)self.length, self.type, self.keyOrController, self.velocityOrValue, self.channel];
}

- (MKMessageType)type {
    return self.length ? (MKMessageType)self.bytes[0] : 0;
}

- (UInt8)keyOrController {
    return self.length ? self.bytes[1] : 0;
}

- (UInt8)velocityOrValue {
    return self.length ? self.bytes[2] : 0;
}

- (UInt8)channel {
    return (self.type & 0x0F) + 1;
}

- (void)setChannel:(UInt8)channel {
    [self setByte:(self.type | channel) atIndex:0];
}

- (void)setType:(MKMessageType)type {
    [self setByte:(type | self.channel) atIndex:0];
}

- (void)setKeyOrController:(UInt8)keyOrController {
    [self setByte:keyOrController atIndex:1];
}

- (void)setVelocityOrValue:(UInt8)velocityOrValue {
    [self setByte:velocityOrValue atIndex:2];
}

- (NSData *)data {
    return (NSData *)self.mutableData;
}

- (UInt8 *)bytes {
    return (UInt8 *)self.mutableData.mutableBytes;
}

- (NSUInteger)length {
    return self.mutableData.length;
}

- (void)setByte:(UInt8)byte atIndex:(NSUInteger)idx {
    if(idx >= self.length) {
        [self.mutableData setLength:idx+1];
    }
    self.bytes[idx] = byte;
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)idx {
    if([object isKindOfClass:[NSNumber class]]) {
        [self setByte:((NSNumber *)object).unsignedCharValue atIndex:idx];
    }
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[MKMessage class]] && [self.mutableData isEqualToData:((MKMessage *)object).mutableData];
}

@end
