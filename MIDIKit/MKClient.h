//
//  MKClient.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

@class MKVirtualDestination, MKVirtualSource;
@class MKInputPort, MKOutputPort;
@class MKDevice, MKEntity, MKDestination, MKSource;
@protocol MKClientNotificationDelegate;


#pragma mark - -Mutual ObjC/JavaScript-

/*
 MKClient is the client class to the system MIDI server.
 It 'owns' or manages any created ports or endpoints,
 and this class has some convenience methods for other things also.
 */

@protocol MKClientJS <JSExport, MKObjectJS>

#pragma mark - -Init-
+ (instancetype)global;
+ (instancetype)clientWithName:(NSString *)name;


#pragma mark - -Child Objects-

#pragma mark Ports
// firstInputPort and firstOutputPort will look to see if there are
// any already-created ports in the arrays below, and if not, create one,
// and return it.
- (MKInputPort *)firstInputPort;
- (MKOutputPort *)firstOutputPort;

// This will create and and insert a port/endpoint into the corresponding array,
// and return it.
- (MKInputPort *)createInputPort;
- (MKOutputPort *)createOutputPort;

// Named port/endpoint instantiation
- (MKInputPort *)createInputPortNamed:(NSString *)name;
- (MKOutputPort *)createOutputPortNamed:(NSString *)name;

#pragma mark Endpoints
- (MKVirtualSource *)createVirtualSource;
- (MKVirtualDestination *)createVirtualDestination;

- (MKVirtualSource *)createVirtualSourceNamed:(NSString *)name;
- (MKVirtualDestination *)createVirtualDestinationNamed:(NSString *)name;


#pragma mark - -CoreMIDI Client Disposal-
// Disposes the MIDIRef(MIDIClientRef) object (invalidates this object)
- (instancetype)dispose;


#pragma mark - -Notifications-
+ (void)startSendingNotifications;
+ (void)stopSendingNotifications;


#pragma mark - -Child Object Containers-
// If the convenience methods for instantiation of ports and endpoints
// on this class is used, they are inserted automatically into these
// containers. If not, you may manually insert your own.
@property (nonatomic, readonly) NSMutableArray *outputPorts;
@property (nonatomic, readonly) NSMutableArray *inputPorts;
@property (nonatomic, readonly) NSMutableArray *virtualSources;
@property (nonatomic, readonly) NSMutableArray *virtualDestinations;

@end


#pragma mark - -Client Wrapper-
@interface MKClient : MKObject <MKClientJS>


#pragma mark - -Global Notificadtion Delegates-
- (instancetype)addNotificationDelegate:(id<MKClientNotificationDelegate>)delegate;
- (instancetype)removeNotificationDelegate:(id<MKClientNotificationDelegate>)delegate;

@end


#pragma mark - -Global Notification Delegate-
@protocol MKClientNotificationDelegate <NSObject>

@optional
#pragma mark - -Object Addition/Removal-

#pragma mark All Objects
// Called when anything is added/removed
- (void)midiClient:(MKClient *)client objectAdded:(MKObject *)object ofType:(MIDIObjectType)type;
- (void)midiClient:(MKClient *)client objectRemoved:(MKObject *)object ofType:(MIDIObjectType)type;

#pragma mark Devices
// Called for add/remove of specific types
- (void)midiClient:(MKClient *)client deviceAdded:(MKDevice *)device;
- (void)midiClient:(MKClient *)client deviceRemoved:(MKDevice *)device;

#pragma mark Entities
- (void)midiClient:(MKClient *)client entityAdded:(MKEntity *)entity;
- (void)midiClient:(MKClient *)client entityRemoved:(MKEntity *)entity;

#pragma mark Sources
- (void)midiClient:(MKClient *)client sourceAdded:(MKSource *)source;
- (void)midiClient:(MKClient *)client sourceRemoved:(MKSource *)source;

#pragma mark Destinations
- (void)midiClient:(MKClient *)client destinationAdded:(MKDestination *)destination;
- (void)midiClient:(MKClient *)client destinationRemoved:(MKDestination *)destination;


#pragma mark - -Updates & Errors-
- (void)midiClient:(MKClient *)client object:(MKObject *)object changedValueOfPropertyForKey:(CFStringRef)key;

// errorCode is a wrapper of an OSStatus
- (void)midiClient:(MKClient *)client driverIOErrorWithDevice:(MKDevice *)driverDevice errorCode:(NSNumber *)errorCode;
- (void)midiClientSetupChanged:(MKClient *)client;
- (void)midiClientThruConnectionsChanged:(MKClient *)client;

@end


#pragma mark - -Notifications-

#pragma mark Names
extern NSString *MKObjectPropertyChangedNotification;

#pragma mark UserInfo Keys
extern NSString *MKUserInfoPropertyNameKey;
extern NSString *MKUserInfoObjectInstanceKey;


#pragma mark - -Client Reference Protocol-
// ---------------------------------------------------
// Protocols used for instaniation/reference to client
@protocol MKClientReference <JSExport>

@property (nonatomic, weak) MKClient *client;

@end


#pragma mark - -Client Instantiation Protocol-
// Common protocol for objects that are created with a parent client
// and a name.
@protocol MKClientDependentInstaniation <NSObject, MKClientReference>

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

@end