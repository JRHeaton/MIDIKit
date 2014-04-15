//
//  MKVirtualSource.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKClient.h"

#pragma mark - -Mutual ObjC/JavaScript-

@protocol MKVirtualSourceJS <JSExport>

JSExportAs(virtualSourceNamed,
+ (instancetype)virtualSourceWithName:(NSString *)name client:(MKClient *)client);

@end

#pragma mark - -Virtual Source Endpoint Wrapper-

// A virtual source is a client-created endpoint that
// is visible to other MIDI clients as a source that they can
// connect to an input port and receive data with, just as they
// would with a normal source.

@interface MKVirtualSource : MKObject <MKClientDependentInstaniation, MKVirtualSourceJS, MKEndpointProperties>

#pragma mark - -Init-
// Creates a new virtual source and adds it to the MIDI server
- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;


#pragma mark - -I/O-
// Virtually sends data from this source.
- (instancetype)receivedData:(NSData *)data;

@property (nonatomic, readonly) NSOperationQueue *receiveQueue;

@end
