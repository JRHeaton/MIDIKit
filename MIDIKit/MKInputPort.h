//
//  MKInputPort.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import "MKEndpoint.h"

@interface MKInputPort : MKObject

- (void)connectSource:(MKEndpoint *)source;
- (void)disconnectSource:(MKEndpoint *)source;

@end
