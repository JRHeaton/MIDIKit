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
        MKOutputPort *output = [[MKOutputPort alloc] initWithName:@"Output" client:client];
        MKInputPort *input = [[MKInputPort alloc] initWithName:@"input" client:client];
        [client enumerateDevicesUsingBlock:^(MKDevice *device) {
            static uint8 buf[3] = { 0x90, 0x34, 31 };
            [output sendData:[NSData dataWithBytes:buf length:3] toEndpoint:device.rootDestination];
            
            [input connectSource:device.rootSource];
        } constructorBlock:nil restrictWithCriteria:^BOOL(MKDevice *rootDev) {
            return [rootDev.name rangeOfString:@"Launchpad"].location != NSNotFound && rootDev.online;
        }];

        CFRunLoopRun();
}

    return 0;
}