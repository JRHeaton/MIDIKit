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

        uint8 buf[3] = { 0x90, 0x44, 31 };
        
        MKClient *client = [MKClient clientWithName:@"Johns Client"];
        MKEndpoint *lp = [MKEndpoint firstDestinationMeetingCriteria:^BOOL(MKEndpoint *candidate) {
            return candidate.online && [candidate.name containsString:@"Launchpad"];
        }];
        UInt8 msg[3] = { 0xb0, 0x00, 0x7f };
        MKOutputPort *outputPort = client.createOutputPort;
        [outputPort sendData:[NSData dataWithBytes:msg length:3] toDestination:lp];

        CFRunLoopRun();
}

    return 0;
}