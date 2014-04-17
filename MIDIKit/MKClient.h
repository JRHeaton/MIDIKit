//
//  MKClient.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKObjectProperties.h"

@class MKVirtualDestination, MKVirtualSource;
@class MKInputPort, MKOutputPort;
@class MKDevice, MKEntity, MKDestination, MKSource;


/*
 MKClient is the client class to the system MIDI server.
 It 'owns' or manages any created ports or endpoints,
 and this class has some convenience methods for other things also.
 */

@protocol MKClientJS <JSExport, MKObjectJS>

+ (instancetype)global;
JSExportAs(named, + (instancetype)clientWithNameJS:(JSValue *)name);

// firstInputPort and firstOutputPort will look to see if there are
// any already-created ports in the arrays below, and if not, create one,
// and return it.
@property (nonatomic, readonly) MKInputPort *firstInputPort;
@property (nonatomic, readonly) MKOutputPort *firstOutputPort;

/// This will create and insert a port/endpoint into the corresponding array, then return it.
- (MKInputPort *)createInputPort;
- (MKOutputPort *)createOutputPort;

// Named port/endpoint instantiation
- (MKInputPort *)createInputPortNamed:(NSString *)name;
- (MKOutputPort *)createOutputPortNamed:(NSString *)name;

- (MKVirtualSource *)createVirtualSource;
- (MKVirtualSource *)createVirtualSourceNamed:(NSString *)name;
- (MKVirtualDestination *)createVirtualDestination;
- (MKVirtualDestination *)createVirtualDestinationNamed:(NSString *)name;

/// Disposes the MIDIRef(MIDIClientRef) object (invalidates this object).
- (instancetype)dispose;

/// Begins sending NSNotifications for MIDI system changes
+ (void)startSendingNotifications;

/// Stops sending notifications.
+ (void)stopSendingNotifications;

// If the convenience methods for instantiation of ports and endpoints
// on this class is used, they are inserted automatically into these
// containers. If not, you may manually insert your own.
@property (nonatomic, readonly) NSMutableArray *outputPorts;
@property (nonatomic, readonly) NSMutableArray *inputPorts;
@property (nonatomic, readonly) NSMutableArray *virtualSources;
@property (nonatomic, readonly) NSMutableArray *virtualDestinations;

@end


@protocol MKClientDelegate;
@interface MKClient : MKObject <MKClientJS, MKClientProperties>

/**
 *  Creates a new client.
 *
 *  @param name The name of the new client.
 *
 *  @return The new client on success, or nil on failure.
 */
+ (instancetype)clientWithName:(NSString *)name;

- (instancetype)addDelegate:(id<MKClientDelegate>)delegate;
- (instancetype)removeDelegate:(id<MKClientDelegate>)delegate;

@property (nonatomic, strong) NSMutableArray *delegates;

@end


@protocol MKClientDelegate <NSObject>

@optional
// Called when anything is added/removed
- (void)midiClient:(MKClient *)client objectAdded:(MKObject *)object ofType:(MIDIObjectType)type;
- (void)midiClient:(MKClient *)client objectRemoved:(MKObject *)object ofType:(MIDIObjectType)type;

// Called for add/remove of specific types
- (void)midiClient:(MKClient *)client deviceAdded:(MKDevice *)device;
- (void)midiClient:(MKClient *)client deviceRemoved:(MKDevice *)device;
- (void)midiClient:(MKClient *)client entityAdded:(MKEntity *)entity;
- (void)midiClient:(MKClient *)client entityRemoved:(MKEntity *)entity;
- (void)midiClient:(MKClient *)client sourceAdded:(MKSource *)source;
- (void)midiClient:(MKClient *)client sourceRemoved:(MKSource *)source;
- (void)midiClient:(MKClient *)client destinationAdded:(MKDestination *)destination;
- (void)midiClient:(MKClient *)client destinationRemoved:(MKDestination *)destination;

- (void)midiClient:(MKClient *)client object:(MKObject *)object changedValueOfPropertyForKey:(CFStringRef)key;

// errorCode is a wrapper of an OSStatus
- (void)midiClient:(MKClient *)client driverIOErrorWithDevice:(MKDevice *)driverDevice errorCode:(NSNumber *)errorCode;
- (void)midiClientSetupChanged:(MKClient *)client;
- (void)midiClientThruConnectionsChanged:(MKClient *)client;

@end


// Notifications
extern NSString *MKObjectPropertyChangedNotification;
// User info keys for notifications
extern NSString *MKUserInfoPropertyNameKey;
extern NSString *MKUserInfoObjectInstanceKey;


/**
 *  Protocol that declares a reference to an owning(parent) client object.
 */
@protocol MKClientReference <JSExport>

/// The parent client.
@property (nonatomic, weak) MKClient *client;

@end


/**
 *  Mutual protocol for objects that are created with a parent client and a name.
 */
@protocol MKClientDependentInstaniation <NSObject, MKClientReference>

/**
 *  Creates a new object with the given name and client.
 *
 *  @param name   The name of the object to create.
 *  @param client The client with which to create the object.
 *
 *  @return A new object.
 */
- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

@end