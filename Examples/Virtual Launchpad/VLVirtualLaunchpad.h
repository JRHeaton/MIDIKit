//
//  VLVirtualLaunchpad.h
//  MIDIKit
//
//  Created by John Heaton on 4/15/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIKit.h"

typedef enum {
    kVLLayoutModeXY = 1,
    kVLLayoutModeDrum = 2
} VLLayoutMode;

@interface VLVirtualLaunchpad : NSObject <MKVirtualDestinationDelegate>

+ (instancetype)launchpadNamed:(NSString *)name;

@property (nonatomic, readonly) MKVirtualDestination *inputDestination;
@property (nonatomic, readonly) MKVirtualSource *outputSource;

- (void)reset;
- (void)setLayoutMode:(VLLayoutMode)mode;

@end
