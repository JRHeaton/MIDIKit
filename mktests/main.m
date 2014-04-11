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

int main(int argc, const char * argv[]){
    @autoreleasepool {
        MKConnection *connection = [MKConnection connectionWithNewClient];
        [connection addDestination:[MKEndpoint objectForUniqueID:LP_ID]];
        
        CFRunLoopRun();
    }

    return 0;
}