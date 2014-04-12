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

int main(int argc, const char * argv[]){
    @autoreleasepool {
        MKJavaScriptContext *c = [MKJavaScriptContext new];
        c[@"LPMessage"] = [LPMessage class];

        NSLog(@"%@", [c evaluateScript:@"MKClient.new()"]);

        NSLog(@"%@", [c evaluateScript:[NSString stringWithContentsOfFile:@"/Users/John/Dropbox/Developer/projects/MIDIKit/mktests/test.js" encoding:NSUTF8StringEncoding error:nil]]);

//        CFRunLoopRun();
    }

    return 0;
}