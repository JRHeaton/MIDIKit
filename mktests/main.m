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

@interface testdev : MKDevice

- (void)test:(MKClient *)client;

@end

@implementation testdev

- (void)test:(MKClient *)client {
    [client sendDataArray:@[ @0xb0, @0x00, @0x7f ] toEndpoint:self.rootDestination];
}

@end

int main(int argc, const char * argv[]){
    @autoreleasepool {

        MKClient *client = [MKClient clientWithName:@"Johns Client"];
        [client enumerateDevicesUsingBlock:^(MKDevice *device) {
            if([device.name isEqualToString:@"Launchpad Mini 4"]) {
                [(testdev *)device test:client];
            }
        } constructorBlock:^MKDevice *(MIDIDeviceRef dev) {
            return [[testdev alloc] initWithMIDIRef:dev];
        }];

        CFRunLoopRun();
}

    return 0;
}