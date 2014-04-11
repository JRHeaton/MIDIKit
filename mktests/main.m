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

#import <JavaScriptCore/JavaScriptCore.h>
#import "NSString+JRExtensions.h"

int main(int argc, const char * argv[]){
    @autoreleasepool {

        MKClient *client = [MKClient clientWithName:@"Johns Client"];
        MKInputPort *in = [client createInputPort];
        in.inputHandler = ^(MKEndpoint *source, NSData *data) {
            for(int i=0;i<data.length;++i) {
                printf("%02x ", ((unsigned char *)data.bytes)[i]);
            }
            puts("");
        };
        
        [client enumerateDevicesUsingBlock:^(MKDevice *device) {
            [in connectSource:device.rootSource];
            
        } constructorBlock:nil
          restrictWithCriteria:^BOOL(MKDevice *rootDev) {
            return rootDev.online && [rootDev.name containsString:@"Launchpad"];
        }];

        CFRunLoopRun();
}

    return 0;
}