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

@protocol MKClientJS <JSExport>

+ (instancetype)clientWithName:(NSString *)name;

// firstInputPort and firstOutputPort will look to see if there are
// any already-created ports in the arrays below, and if not, create one,
// and return it.
- (MKInputPort *)firstInputPort;
- (MKOutputPort *)firstOutputPort;

// This will create and and insert a port into the corresponding array,
// and return it.
- (MKInputPort *)createInputPort;
- (MKOutputPort *)createOutputPort;

// Disposes the MIDIRef(MIDIClientRef) object (invalidates this object)
- (void)dispose;

// These create and insert virtual endpoints and return them
- (MKVirtualSource *)createVirtualSourceNamed:(NSString *)name;
- (MKVirtualDestination *)createVirtualDestinationNamed:(NSString *)name;

// If the convenience methods for instantiation of ports and endpoints
// on this class is used, they are inserted automatically into these
// containers. If not, you may manually insert your own.
@property (nonatomic, readonly) NSMutableArray *outputPorts;
@property (nonatomic, readonly) NSMutableArray *inputPorts;
@property (nonatomic, readonly) NSMutableArray *virtualSources;
@property (nonatomic, readonly) NSMutableArray *virtualDestinations;

@end

@interface MKClient : MKObject <MKClientJS>

// Not sure yet...
- (void)addNotificationDelegate:(id<MKClientNotificationDelegate>)delegate;
- (void)removeNotificationDelegate:(id<MKClientNotificationDelegate>)delegate;

@end

@protocol MKClientReference <NSObject, JSExport>

@property (nonatomic, weak) MKClient *client;

@end

// Common protocol for objects that are created with a parent client
// and a name.
@protocol MKClientDependentInstaniation <NSObject>

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

@end

@protocol MKClientNotificationDelegate <NSObject>

- (void)midiClient:(MKClient *)client objectConnected:(MKObject *)object ofType:(MIDIObjectType)type;
- (void)midiClient:(MKClient *)client objectDisconnected:(MKObject *)object ofType:(MIDIObjectType)type;
- (void)midiClient:(MKClient *)client object:(MKObject *)object changedValueOfPropertyForKey:(CFStringRef)key;

@end