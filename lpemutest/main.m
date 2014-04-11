//
//  main.m
//  lpemutest
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIKit.h"
#import "JRVirtualLaunchpad.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        JRVirtualLaunchpad *lp = [[JRVirtualLaunchpad alloc] initWithName:@"FakeLPJ" client:[MKClient clientWithName:@"Testy"]];
        CFRunLoopRun();
    }
    return 0;
}

