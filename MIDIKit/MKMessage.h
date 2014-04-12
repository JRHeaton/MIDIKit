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
    kMKMessageTypeNoteOn = 0x90,
    kMKMessageTypeNoteOff = 0x80,
    kMKMessageTypeControlChange = 0xB0
};

// MKMessage is a data wrapper class which implements some basic MIDI
// message protocol logic.
//
// It is mainly meant to be extended for generating messages
// that correspond to specific sets of functions for specific
// types of devices. For instance, you could subclass this
// for generating messages that correspond to light commands
// on a pad device.

@protocol MKMessageJS <JSExport>

JSExportAs(message,
+ (instancetype)messageWithType:(MKMessageType)type
                keyOrController:(UInt8)keyOrController
                velocityOrValue:(UInt8)velocityOrValue);

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

@end

@interface MKMessage : NSObject <MKMessageJS>

+ (instancetype)controlChangeMessageWithController:(UInt8)controller value:(UInt8)value;

+ (instancetype)messageWithData:(NSData *)data;
+ (instancetype)messageWithPacket:(MIDIPacket *)packet;

- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithPacket:(MIDIPacket *)packet;
- (instancetype)initWithType:(MKMessageType)type
             keyOrController:(UInt8)keyOrController
             velocityOrValue:(UInt8)velocityOrValue;

// Hacky, but useful...
+ (instancetype):(UInt8)type :(UInt8)keyOrController :(UInt8)velocityOrValue;

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)idx;

@end
