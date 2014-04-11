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
    return (self.type & 0x0F);
}

- (void)setType:(MKMessageType)type {
    [self setByte:type atIndex:0];
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
    if(![object isKindOfClass:[NSNumber class]]) return;
    [self setByte:((NSNumber *)object).unsignedCharValue atIndex:idx];
}

@end
