//
//  MKInputPort.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKEntity.h"
#import "MKClient.h"

@interface MKInputPort : MKObject <MKClientDependentInstaniation>

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

- (void)connectSource:(MKEndpoint *)source;
- (void)disconnectSource:(MKEndpoint *)source;

- (void)dispose;

@end
