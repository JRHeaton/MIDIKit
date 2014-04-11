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

#import "NSString+JRExtensions.h"

int main(int argc, const char * argv[]){
    @autoreleasepool {

        MKClient *client = [MKClient clientWithName:@"Johns Client"];
        [client enumerateDevicesUsingBlock:^(MKDevice *device) {
            NSLog(@"%@", device);
        }];

        CFRunLoopRun();
}

    return 0;
}