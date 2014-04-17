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

/**
 *  Creates a new message with the global client.
 *
 *  @return A new, empty message.
 */
+ (instancetype)new;
// Convnenience for converting from one class to another
// Usually, this is done because a subclass of MKMessage is
// implementing logic.
/**
 *  Instantiates a new message with the same data as the given message. 
 *  Helpful for using subclasses when you're handed an MKMessage.
 *
 *  @param message The message whose data is to be used.
 *
 *  @return The new message.
 */
+ (instancetype)subclass:(MKMessage *)message;

/**
 *  Instantiates a new message with a copy of the give message's data.
 *  Helpful for using subclasses when you're handed an MKMessage.
 *
 *  @param message The message whose data is to be copied.
 *
 *  @return The new message.
 */
+ (instancetype)copy:(MKMessage *)message;

JSExportAs(withType,        + (instancetype)messageWithType:(MKMessageType)type);
JSExportAs(withStatus,      + (instancetype)messageWithStatus:(UInt8)status :(UInt8)data1 :(UInt8)data2);

JSExportAs(controlChange,   + (instancetype)controlChangeMessageWithController:(UInt8)controller value:(UInt8)value);
JSExportAs(noteOn,          + (instancetype)noteOnMessageWithKey:(UInt8)key velocity:(UInt8)velocity);

JSExportAs(withMessage,     + (instancetype)messageWithMessage:(MKMessage *)message);

// Cleaner syntax for variable-length messages: MKMessage.message(0xf0, 0xa, 0xb, 0xc, 0xd, 0xf7)
JSExportAs(message,         + (instancetype)messageJS:(JSValue *)val);

// Same, but for many messages in one stream of arguments
JSExportAs(messages,        + (NSArray *)messagesJS:(JSValue *)val);

// Convenience/accessibility for JavaScript
+ (MKMessageType)noteOnType;
+ (MKMessageType)noteOffType;
+ (MKMessageType)controlChangeType;
+ (MKMessageType)polyphonicAfterTouchType;
+ (MKMessageType)programChangeType;
+ (MKMessageType)channelAfterTouchType;
+ (MKMessageType)pitchBendType;
+ (MKMessageType)sysexType;

/// The length of the data of this message.
- (NSUInteger)length;

// These will expand the data length to fit.
/**
 *  Sets a single byte at a given place in the message's data buffer.
 *  The message will grow if it needs to.
 *
 *  @param byte  The value to apply.
 *  @param index The index at which to
 *
 *  @return self (for chaining)
 */
- (instancetype)setByte:(UInt8)byte atIndex:(NSUInteger)index;

/// The MIDI channel of this message.
@property (nonatomic, assign) UInt8 channel;

/// The identity of this message.
@property (nonatomic, assign) MKMessageType type;

/// The full first byte.
@property (nonatomic, assign) UInt8 status;

/**
 *  These all get/set the second byte.
 *  They are named conveniently for parts of common message types.
 *
 *  key:            note messages
 *  controller:     control change messages
 *  programNumber:  program change messages
 *  data1:          generic
 */
@property (nonatomic, assign) UInt8 key, controller, programNumber, data1;

/**
 *  These all get/set the third byte.
 *  They are named conveniently for parts of common message types.
 *
 *  velocity:       note messages
 *  value:          control change messages
 *  pressures:      aftertouch messages
 *  data2:          generic
 */
@property (nonatomic, assign) UInt8 velocity, value, pressure, data2;


JSExportAs(setChannel, - (instancetype)setChannelReturn:(UInt8)channel);
JSExportAs(setType, - (instancetype)setTypeReturn:(MKMessageType)type);
JSExportAs(setStatus, - (instancetype)setStatusReturn:(UInt8)status);
JSExportAs(setKey, - (instancetype)setKeyReturn:(UInt8)key);
JSExportAs(setController, - (instancetype)setControllerReturn:(UInt8)controller);
JSExportAs(setData1, - (instancetype)setData1Return:(UInt8)data1);
JSExportAs(setData2, - (instancetype)setData2Return:(UInt8)data2);
JSExportAs(setVelocity, - (instancetype)setVelocityReturn:(UInt8)velocity);

/// Whether the message is zero-length or zeroed out.
@property (nonatomic, readonly, getter = isEmpty) BOOL empty;

@end


/**
 *  MKMessage is a data wrapper class which implements some basic MIDI
 *  message protocol logic. It abstracts away the fuss of technical MIDI
 *  data parsing/manipulation, and gives an easy-to-use interface for
 *  manipulating properties of the data more expressively.
 *
 *  It can also be subclassed and extended for generating/parsing messages
 *  that correspond to specific sets of functions for specific
 *  types of devices. For instance, you could subclass this
 *  for generating messages that correspond to light commands
 *  on a pad device.
 */
@interface MKMessage : NSObject <MKMessageJS>

+ (instancetype)messageWithData:(NSData *)data;
+ (instancetype)messageWithPacket:(MIDIPacket *)packet;

+ (NSArray *)messagesWithData:(NSData *)data;
+ (NSArray *)messagesWithPacket:(MIDIPacket *)packet;
+ (NSArray *)messagesWithPacketList:(MIDIPacketList *)list;

+ (instancetype):(UInt8)status :(UInt8)data1 :(UInt8)data2;

/// The wrapped mutable data object.
- (NSMutableData *)data;

/// The wrapped mutable data.
- (UInt8 *)bytes;


// myMessage[0] = @(0x90)
// This ONLY works with one-byte NSNumbers
/**
 *  Subscripting support.
 *
 *  @param number A one-byte unsigned NSNumber.
 *  @param idx    The index to set this byte at in the data buffer.
 *
 *  @return self (for chaining).
 */
- (instancetype)setObject:(NSNumber *)number atIndexedSubscript:(NSUInteger)idx;

@end
