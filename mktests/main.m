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

        LPDev *dev = [LPDev firstLaunchpadMiniWithClient:client];
        [dev sendPadMessageToX:2 y:4 red:3 green:0 copy:0 clear:1];
        [client connectSourceToInputPort:dev.rootSource];

        CFRunLoopRun();

    }

    return 0;
}

