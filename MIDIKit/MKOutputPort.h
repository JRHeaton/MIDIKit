//
//  MKOutputPort.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKClient.h"

@interface MKOutputPort : MKObject <MKClientDependentInstaniation>

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;
- (void)dispose;

- (void)sendData:(NSData *)data toDestination:(MKEndpoint *)endpoint;

@end
