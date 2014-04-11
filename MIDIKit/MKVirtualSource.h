//
//  MKVirtualSource.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEndpoint.h"
#import "MKClient.h"

@interface MKVirtualSource : MKEndpoint <MKClientDependentInstaniation>

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

- (void)receivedData:(NSData *)data;

@end
