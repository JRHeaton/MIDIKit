//
//  VLAppDelegate.m
//  Virtual Launchpad
//
//  Created by John Heaton on 4/15/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "VLAppDelegate.h"
#import "VLVirtualLaunchpad.h"

@implementation VLAppDelegate

VLVirtualLaunchpad *lp;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    lp = [VLVirtualLaunchpad launchpadNamed:@"FakePad"];
}

@end
