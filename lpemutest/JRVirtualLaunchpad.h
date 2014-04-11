//
//  JRVirtualLaunchpad.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIKit.h"

@class LPMessage;
@interface JRVirtualLaunchpad : NSObject <MKClientDependentInstaniation, MKVirtualDestinationDelegate> {
    MKVirtualDestination *vDest;
    MKVirtualSource *vSource;
}

- (void)handleMessage:(LPMessage *)message;
- (void)handleData:(NSData *)midi;

- (void)reset;

@end
