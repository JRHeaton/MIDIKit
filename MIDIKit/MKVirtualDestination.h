//
//  MKVirtualDestination.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEndpoint.h"
#import "MKClient.h"

@protocol MKVirtualDestinationDelegate;
@interface MKVirtualDestination : MKEndpoint <MKClientDependentInstaniation>

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

- (void)addDelegate:(id<MKVirtualDestinationDelegate>)delegate;
- (void)removeDelegate:(id<MKVirtualDestinationDelegate>)delegate;

@end

@protocol MKVirtualDestinationDelegate <NSObject>

- (void)virtualDestination:(MKVirtualDestination *)virtualDestination
              receivedData:(NSData *)data;

@end
