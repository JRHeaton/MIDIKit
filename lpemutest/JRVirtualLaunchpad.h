//
//  JRVirtualLaunchpad.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIKit.h"

@interface JRVirtualLaunchpad : NSObject <MKClientDependentInstaniation, MKVirtualDestinationDelegate> {
    MKVirtualDestination *vDest;
    MKVirtualSource *vSource;
}

@end
