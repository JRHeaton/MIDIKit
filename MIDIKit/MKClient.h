//
//  MKClient.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKDevice.h"
#import "MKInputPort.h"

// The client object is essentially your root interface
// to the MIDI server. In this context, it also encapsulates
// a good amount of convenience/enumeration logic as well.
//
// Some objects support assigning the 'client' property on them
// which allows for them to delegate some behavior back to
// that client for convenience. (For example, sending data)

@protocol MKClientNotificationDelegate;
@interface MKClient : MKObject

// Creates a new device with the given name
// NOTE: passing nil here or calling -init/+new
// will create a client with the following format:
// "<progname>-client"
// You are not required to format the name in any
// particular way
+ (instancetype)clientWithName:(NSString *)name;

- (void)enumerateDevicesUsingBlock:(void (^)(MKDevice *device))enumerationBlock
                  constructorBlock:(MKDevice *(^)(MIDIDeviceRef dev))constructorBlock;
- (MKDevice *)deviceAtIndex:(NSUInteger)index;

// Send a chunk of data to a given endpoint as a standard MIDI message
// NOTE: the timeStamp on this message will be 0 (immediate)
- (void)sendData:(NSData *)data toEndpoint:(MKEndpoint *)endpoint;

// This is a convenience method which takes an array of NSNumbers,
// whose values are unsigned one-byte values to be inserted into the
// MIDI packet list(s) before sending.
// Therefore, this syntax can be used: @[ @0x90, @0xaa, @127 ]
- (void)sendDataArray:(NSArray *)array toEndpoint:(MKEndpoint *)endpoint;

- (void)addNotificationDelegate:(id<MKClientNotificationDelegate>)delegate;
- (void)removeNotificationDelegate:(id<MKClientNotificationDelegate>)delegate;

// Handy dynamic enumeration properties
// NOTE: These are SYNCHRONOUS, and when they're called
// for the first time in a new process, the MIDI server
// takes a couple of seconds to enumerate everything.
// It's probably recommended that you get this on a secondary thread
@property (nonatomic, readonly) NSUInteger numberOfDevices;
@property (nonatomic, readonly) NSUInteger numberOfDestinations;
@property (nonatomic, readonly) NSUInteger numberOfSources;

// These are wrapper objects for the auto-created input and output ports
// of this client.
@property (nonatomic, readonly) MKObject *outputPort;
@property (nonatomic, readonly) MKInputPort *inputPort;

@end
