//
//  main.m
//  mktests
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIKit.h"
#import "LPMessage.h"

#import "NSString+JRExtensions.h"

#define LP_ID 0xf0b43c3a

void test_javascript() {
    
}

int main(int argc, const char * argv[]){
    @autoreleasepool {
        JSContext *c = [JSContext new];
        c[@"client"] = [MKClient clientWithName:@"fart"];
        c[@"lp"] = [MKEndpoint firstOnlineDestinationNamed:@"Launchpad Mini 4"];
        NSLog(@"%@", [c evaluateScript:@"client.firstOutputPort().send([0xb0, 0x00, 0x00], lp)"]);
        
        CFRunLoopRun();
    }

    return 0;
}