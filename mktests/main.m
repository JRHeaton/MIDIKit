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

#import "MKJavaScriptContext.h"
#import "NSString+JRExtensions.h"

#define LP_ID 0xf0b43c3a

void test_javascript() {
    
}

int main(int argc, const char * argv[]){
    @autoreleasepool {
        
        MKConnection *cc =    [MKConnection connectionWithNewClient];
        [cc addDestination:[MKEndpoint firstOnlineDestinationNamed:@"Launchpad Mini 4"]];
//        [cc sendMessage:LPMessage.reset];
        
        MKJavaScriptContext *c = [MKJavaScriptContext new];
        c[@"lpmsg"] = [LPMessage class];
        NSError *e;
        NSLog(@"%@", [c evaluateScript:[NSString stringWithContentsOfFile:@"/Users/John/Dropbox/Developer/projects/MIDIKit/mktests/test.js" encoding:NSASCIIStringEncoding error:&e]]);

        
        CFRunLoopRun();
    }

    return 0;
}