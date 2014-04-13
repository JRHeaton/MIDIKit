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

@dynamic type, key, controller, velocity, status, data1, data2;

#pragma mark - Types

+ (MKMessageType)noteOnType {
    return kMKMessageTypeNoteOn;
}

+ (MKMessageType)noteOffType {
    return kMKMessageTypeNoteOff;
}

+ (MKMessageType)controlChangeType {
    return kMKMessageTypeControlChange;
}

+ (MKMessageType)polyphonicAfterTouchType {
    return kMKMessageTypePolyphonicKeyPressureAfterTouch;
}

+ (MKMessageType)programChangeType {
    return kMKMessageTypeProgramChange;
}

+ (MKMessageType)channelAfterTouchType {
    return kMKMessageTypeChannelPressureAfterTouch;
}

+ (MKMessageType)pitchBendType {
    return kMKMessageTypePitchBend;
}


#pragma mark - Init

- (instancetype)init {
    if(!(self = [super init])) return nil;
    _mutableData = [NSMutableData dataWithLength:3];
    return self;
}

+ (instancetype)controlChangeMessageWithController:(UInt8)controller value:(UInt8)value {
    return [[self alloc] initWithStatus:kMKMessageTypeControlChange :controller :value];
}

+ (instancetype)noteOnMessageWithKey:(UInt8)key velocity:(UInt8)velocity {
    return [[self alloc] initWithStatus:kMKMessageTypeNoteOn :key :velocity];
}

+ (instancetype)messageWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

+ (instancetype)messageWithPacket:(MIDIPacket *)packet {
    return [[self alloc] initWithPacket:packet];
}

+ (NSArray *)messagesWithData:(NSData *)data {
    NSMutableArray *ret = [NSMutableArray array];

#define NUM_TYPES 8
    static MKMessageType handledTypes[NUM_TYPES] = {
        kMKMessageTypeNoteOff,
        kMKMessageTypeNoteOn,
        kMKMessageTypePolyphonicKeyPressureAfterTouch,
        kMKMessageTypeControlChange,
        kMKMessageTypeProgramChange,
        kMKMessageTypeChannelPressureAfterTouch,
        kMKMessageTypePitchBend,
        kMKMessageTypeSysex
    };
    UInt8 *buff = (UInt8 *)data.bytes;

    UInt8 off = 0;
    while(off < data.length) {
        UInt8 *buf = &buff[off];

        bool found = false;
        for(int i=0;i<NUM_TYPES;++i) {
            MKMessageType type = handledTypes[i];

            if((buf[0] & 0xf0) == type) {
                UInt8 goodLen = (data.length - off);
                switch (type) {
                    case kMKMessageTypeSysex:
                        for(NSUInteger x=0;x<goodLen;++x) {
                            if(buf[x] == 0xF7) { // EOX
                                goodLen = x + 1;
                                goto done;
                            }
                        }

                        break;
                    default: goodLen = MIN(3, goodLen); // standard MIDI message
                }
            done:

                [ret addObject:[MKMessage messageWithData:[NSData dataWithBytes:buf length:goodLen]]];

                off += goodLen;
                found = true;
            }
        }
        if(found)
            found = false;
        else
            off++;
    }
#undef NUM_TYPES

    return ret;
}

+ (NSArray *)messagesWithPacket:(MIDIPacket *)packet {
    return [self messagesWithData:[NSData dataWithBytesNoCopy:packet->data length:packet->length freeWhenDone:NO]];
}

+ (NSArray *)messagesWithPacketList:(MIDIPacketList *)list {
    NSMutableArray *ret = [NSMutableArray array];

    MIDIPacket *packet = &list->packet[0];
    for (int i=0;i<list->numPackets;++i) {
        packet = MIDIPacketNext(packet);
        [ret addObjectsFromArray:[self messagesWithPacket:packet]];
    }

    return ret.count ? ret.copy : nil;
}

- (instancetype)initWithData:(NSData *)data {
    if(!(self = [self init])) return nil;
    _mutableData = data ? ([data isKindOfClass:[NSMutableData class]] ? data : data.mutableCopy) : [NSMutableData dataWithCapacity:0];
    return self;
}

- (instancetype)initWithPacket:(MIDIPacket *)packet {
    if(!(self = [self init])) return nil;
    
    [self.mutableData setLength:packet->length];
    memcpy(self.bytes, packet->data, packet->length);
    
    return self;
}

- (instancetype)initWithStatus:(UInt8)status :(UInt8)data1 :(UInt8)data2 {
    if(!(self = [self init])) return nil;

    self.status = status;
    self.data1 = data1;
    self.data2 = data2;

    return self;
}

+ (instancetype):(UInt8)status :(UInt8)data1 :(UInt8)data2 {
    return [[self alloc] initWithStatus:status :data1 :data2];
}

- (NSString *)_hexStringForData:(NSData *)data maxByteCount:(NSUInteger)max {
    NSMutableString *str = [NSMutableString string];

    for(NSUInteger i=0;i<MIN(max, data.length); ++i) {
        BOOL atDataEnd = (i == (data.length - 1));
        BOOL atMax = (i == (max - 1));
        [str appendFormat:@"0x%02X%@", ((unsigned char *)data.bytes)[i], (atMax && !atDataEnd) ? @", ..." : (atDataEnd ? @"" : @" ")];
    }

    return str;
}

- (NSString *)description {
    NSString *typeName;
    switch (self.type) {
        case kMKMessageTypeSysex: typeName = @"Sysex"; break;
        case kMKMessageTypeChannelPressureAfterTouch: typeName = @"Channel AfterTouch"; break;
        case kMKMessageTypeControlChange: typeName = @"Control Change"; break;
        case kMKMessageTypeNoteOff: typeName = @"Note Off"; break;
        case kMKMessageTypeNoteOn: typeName = @"Note On"; break;
        case kMKMessageTypePitchBend: typeName = @"Pitch Bend"; break;
        case kMKMessageTypePolyphonicKeyPressureAfterTouch: typeName = @"Polyphonic AfterTouch"; break;
        case kMKMessageTypeProgramChange: typeName = @"Program Change"; break;
        default: typeName = @"Unknown"; break;
    }

    NSString *dataString;
    switch (self.type) {
        case kMKMessageTypeSysex: dataString = [self _hexStringForData:self.data maxByteCount:20]; break;
        default: dataString = [NSString stringWithFormat:@"0x%02X, 0x%02X, 0x%02X", self.status, self.data1, self.data2];
    }

    return [NSString stringWithFormat:@"%@ type=0x%X(%@), length=0x%lX, data={%@}", super.description, self.type, typeName, (unsigned long)self.length, dataString];
}

- (MKMessageType)type {
    return self.length ? (MKMessageType)(self.bytes[0] & 0xF0) : 0;
}

- (UInt8)status {
    return self.length ? self.bytes[0] : 0;
}

- (UInt8)data1 {
    return self.length > 1 ? self.bytes[1] : 0;
}

- (UInt8)data2 {
    return self.length > 2 ? self.bytes[2] : 0;
}

- (void)setData1:(UInt8)data1 {
    [self setByte:data1 atIndex:1];
}

- (void)setData2:(UInt8)data2 {
    [self setByte:data2 atIndex:2];
}

#define FORWARD(newGetter, oldGetter, newSetter, oldSetter) \
- (UInt8)newGetter { return self.oldGetter; } \
- (void)newSetter:(UInt8)val { [self oldSetter:val]; }

FORWARD(key, data1, setKey, setData1)
FORWARD(controller, data1, setController, setData1)
FORWARD(velocity, data2, setVelocity, setData2)

#undef FORWARD

- (UInt8)channel {
    return (self.bytes[0] & 0x0F) + 1;
}

- (void)setChannel:(UInt8)channel {
    [self setByte:(self.type | (MAX(1, MIN(16, channel)) - 1)) atIndex:0];
}

- (void)setType:(MKMessageType)type {
    [self setByte:(type | (self.channel - 1)) atIndex:0];
}

- (void)setKeyOrController:(UInt8)keyOrController {
    [self setByte:keyOrController atIndex:1];
}

- (void)setVelocityOrValue:(UInt8)velocityOrValue {
    [self setByte:velocityOrValue atIndex:2];
}

- (NSMutableData *)data {
    return self.mutableData;
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
