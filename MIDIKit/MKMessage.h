//
//  MKMessage.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <JavaScriptCore/JavaScriptCore.h>

// MKMessage is a data wrapper class which implements some basic MIDI
// message protocol logic.
//
// It is mainly meant to be extended for generating messages
// that correspond to specific sets of functions for specific
// types of devices. For instance, you could subclass this
// for generating messages that correspond to light commands
// on a pad device

typedef NS_ENUM(UInt8, MKMessageType) {
    kMKMessageTypeNoteOff                           = 0x80,
    kMKMessageTypeNoteOn                            = 0x90,
    kMKMessageTypePolyphonicKeyPressureAfterTouch   = 0xA0,
    kMKMessageTypeControlChange                     = 0xB0,
    kMKMessageTypeProgramChange                     = 0xC0,
    kMKMessageTypeChannelPressureAfterTouch         = 0xD0,
    kMKMessageTypePitchBend                         = 0xE0,
    kMKMessageTypeSysex                             = 0xF0
};

@class MKMessage;
@protocol MKMessageJS <JSExport>

+ (instancetype)new;
JSExportAs(withType, + (instancetype)messageWithType:(MKMessageType)type);
JSExportAs(withStatus, + (instancetype)messageWithStatus:(UInt8)status :(UInt8)data1 :(UInt8)data2);

JSExportAs(controlChange, + (instancetype)controlChangeMessageWithController:(UInt8)controller value:(UInt8)value);
JSExportAs(noteOn, + (instancetype)noteOnMessageWithKey:(UInt8)key velocity:(UInt8)velocity);

// Convnenience for converting from one class to another
// Usually, this is done because a subclass of MKMessage is
// implementing logic.
+ (instancetype)subclass:(MKMessage *)message;
+ (instancetype)copy:(MKMessage *)message;
JSExportAs(withMessage, + (instancetype)messageWithMessage:(MKMessage *)message);

// Cleaner syntax for variable-length messages: MKMessage.message(0xf0, 0xa, 0xb, 0xc, 0xd, 0xf7)
JSExportAs(message,
+ (instancetype)messageJS:(JSValue *)val
);

// Same, but for many messages in one stream of arguments
JSExportAs(messages,
+ (NSArray *)messagesJS:(JSValue *)val
);

// Convenience/accessibility for JavaScript
+ (MKMessageType)noteOnType;
+ (MKMessageType)noteOffType;
+ (MKMessageType)controlChangeType;
+ (MKMessageType)polyphonicAfterTouchType;
+ (MKMessageType)programChangeType;
+ (MKMessageType)channelAfterTouchType;
+ (MKMessageType)pitchBendType;
+ (MKMessageType)sysexType;

// Shortcut for data.length
- (NSUInteger)length;

// These will expand the data length to fit.
- (instancetype)setByte:(UInt8)byte atIndex:(NSUInteger)index;

// Channel of the note message
@property (nonatomic, assign) UInt8 channel;
// Type of message
@property (nonatomic, assign) MKMessageType type;

// 1st, 2nd and 3rd bytes of the message
// All of these properties access/set the same corresponding byte
// status byte containing type and channel
@property (nonatomic, assign) UInt8 status;
// key for note messages, controller for control change/other
@property (nonatomic, assign) UInt8 key, controller, data1;
// velocity for note messages
@property (nonatomic, assign) UInt8 velocity, data2;

@end

@interface MKMessage : NSObject <MKMessageJS>

+ (instancetype)messageWithData:(NSData *)data;
+ (instancetype)messageWithPacket:(MIDIPacket *)packet;

+ (NSArray *)messagesWithData:(NSData *)data;
+ (NSArray *)messagesWithPacket:(MIDIPacket *)packet;
+ (NSArray *)messagesWithPacketList:(MIDIPacketList *)list;

+ (instancetype):(UInt8)status :(UInt8)data1 :(UInt8)data2;

// Messages stay mutable for performance reasons
- (NSMutableData *)data;
- (UInt8 *)bytes;

// myMessage[0] = @(0x90)
// This ONLY works with one-byte NSNumbers
- (instancetype)setObject:(id)object atIndexedSubscript:(NSUInteger)idx;

@end
