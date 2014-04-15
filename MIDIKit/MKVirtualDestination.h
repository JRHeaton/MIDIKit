//
//  MKVirtualDestination.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKClient.h"

#pragma mark - -Mutual ObjC/JavaScript-

@protocol MKVirtualDestinationJS<JSExport, MKObjectJS>

JSExportAs(named, + (instancetype)virtualDestinationWithName:(NSString *)name client:(MKClient *)client);

@end

#pragma mark - -Virtual Destination Endpoint Wrapper-

// A virtual destination is a client-created endpoint
// that is usable by other clients just like a normal destination.

@protocol MKVirtualDestinationDelegate;
@interface MKVirtualDestination : MKObject <MKClientDependentInstaniation, MKVirtualDestinationJS, MKEndpointProperties>

#pragma mark - -Init-
// Creates a new virtual destination and adds it to the MIDI server
- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;


#pragma mark - -Data Delegates-
// Adds a new delegate to be notified when data is received
- (instancetype)addDelegate:(id<MKVirtualDestinationDelegate>)delegate;
- (instancetype)removeDelegate:(id<MKVirtualDestinationDelegate>)delegate;

@end


#pragma mark - -Virtual Destination Data Delegate-
@protocol MKVirtualDestinationDelegate <NSObject>

// Called when a packet is received
- (void)virtualDestination:(MKVirtualDestination *)virtualDestination
              receivedData:(NSData *)data;

@end
