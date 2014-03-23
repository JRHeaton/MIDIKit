//
//  main.m
//  mktests
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIKit.h"
#import "LPDev.h"

int main(int argc, const char * argv[]){
    @autoreleasepool {
        MKClient *client = [MKClient clientWithName:@"Johns Client"];
        [MKDevice registerClass:[LPDev class] forCriteria:^BOOL(MKObject *obj) {
            return [obj.name isEqualToString:@"Launchpad Mini 4"];
        }];

        [client enumerateDevicesUsingBlock:^(MKDevice *device) {
            if(device.online && [device isKindOfClass:[LPDev class]]) {
                LPDev *d = (LPDev *)device;
                NSLog(@"%@", d);
                [d reset];
            }
        }];
    }

    CFRunLoopRun();

    return 0;
}

