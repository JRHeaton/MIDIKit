//
//  MKClient.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKDevice.h"

/*
 MKClient is the client class to the system MIDI server.
 It 'owns' or manages any created ports or endpoints,
 and this class has some convenience methods for other things also.
 */

@class MKInputPort, MKOutputPort, MKVirtualSource, MKVirtualDestination;
@protocol MKClientNotificationDelegate;
@interface MKClient : MKObject

+ (instancetype)clientWithName:(NSString *)name;

/*
 This will enumerate through all devices, filter out ones you don't want,
 and even allow you to hook in and instantiated a custom subclass of MKDevice
 to pass to the enumeration block.
 */
- (void)enumerateDevicesUsingBlock:(void (^)(MKDevice *device))enumerationBlock
                  constructorBlock:(MKDevice *(^)(MKDevice *rootDev))constructorBlock
              restrictWithCriteria:(BOOL (^)(MKDevice *rootDev))criteriaBlock;

// Wrapper for device at index
- (MKDevice *)deviceAtIndex:(NSUInteger)index;

// Not sure yet...
- (void)addNotificationDelegate:(id<MKClientNotificationDelegate>)delegate;
- (void)removeNotificationDelegate:(id<MKClientNotificationDelegate>)delegate;

// Disposes the MIDIRef(MIDIClientRef) object (invalidates this object)
- (void)dispose;

// firstInputPort and firstOutputPort will look to see if there are
// any already-created ports in the arrays below, and if not, create one,
// and return it.
- (MKInputPort *)firstInputPort;
- (MKOutputPort *)firstOutputPort;

// This will create and and insert a port into the corresponding array,
// and return it.
- (MKInputPort *)createInputPort;
- (MKOutputPort *)createOutputPort;

// These create and insert virtual endpoints and return them
- (MKVirtualSource *)createVirtualSourceNamed:(NSString *)name;
- (MKVirtualDestination *)createVirtualDestinationNamed:(NSString *)name;

// These are dynamic getters that reflect the current state of the MIDI server
@property (nonatomic, readonly) NSUInteger numberOfDevices;
@property (nonatomic, readonly) NSUInteger numberOfDestinations;
@property (nonatomic, readonly) NSUInteger numberOfSources;

// If the convenience methods for instantiation of ports and endpoints
// on this class is used, they are inserted automatically into these
// containers. If not, you may manually insert your own.
@property (nonatomic, readonly) NSMutableArray *outputPorts;
@property (nonatomic, readonly) NSMutableArray *inputPorts;
@property (nonatomic, readonly) NSMutableArray *virtualSources;
@property (nonatomic, readonly) NSMutableArray *virtualDestinations;

@end

// Common protocol for objects that are created with a parent client
// and a name.
@protocol MKClientDependentInstaniation <NSObject>

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

@property (nonatomic, weak) MKClient *client;

@end

@protocol MKClientNotificationDelegate <NSObject>

- (void)midiClient:(MKClient *)client objectConnected:(MKObject *)object ofType:(MIDIObjectType)type;
- (void)midiClient:(MKClient *)client objectDisconnected:(MKObject *)object ofType:(MIDIObjectType)type;
- (void)midiClient:(MKClient *)client object:(MKObject *)object changedValueOfPropertyForKey:(CFStringRef)key;

@end