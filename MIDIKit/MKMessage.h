//
//  MKMessage.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

typedef NS_ENUM(UInt8, MKMessageType) {
    kMKMessageTypeNoteOn = 0x90,
    kMKMessageTypeNoteOff = 0x80,
    kMKMessageTypeControlChange = 0xB0
};

@interface MKMessage : NSObject

+ (instancetype)controlChangeMessageWithController:(UInt8)controller value:(UInt8)value;

+ (instancetype)messageWithData:(NSData *)data;
+ (instancetype)messageWithPacket:(MIDIPacket *)packet;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithPacket:(MIDIPacket *)packet;

// First 3 bytes of the buffer(zero if doesn't exist)
@property (nonatomic, assign) MKMessageType type;
@property (nonatomic, assign) UInt8 keyOrController;
@property (nonatomic, assign) UInt8 velocityOrValue;

// Channel of the note message
@property (nonatomic, assign) UInt8 channel;

- (NSData *)data;

// This is mutable
- (UInt8 *)bytes;

// Shortcut for data.length
- (NSUInteger)length;

// These will expand the data length to fit.
// Subscripting example: myMessage[0] = @(0x90);
- (void)setByte:(UInt8)byte atIndex:(NSUInteger)index;
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)idx;

@end
