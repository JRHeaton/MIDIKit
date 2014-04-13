
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

@interface ClientTest : NSObject <MKClientNotificationDelegate>

@end

@implementation ClientTest

- (void)midiClient:(MKClient *)client objectAdded:(MKObject *)object ofType:(MIDIObjectType)type {
    NSLog(@"Object added: %@, client=%@, type=%d", object, client, type);
}

- (void)midiClient:(MKClient *)client object:(MKObject *)object changedValueOfPropertyForKey:(CFStringRef)key {
    NSLog(@"key change %@", (__bridge NSString *)key);
}

- (void)midiClient:(MKClient *)client destinationAdded:(MKEndpoint *)destination {
    UInt8 buf[3] = {0xb0, 0x00, 0x7f};
    [client.firstOutputPort sendData:[NSData dataWithBytes:buf length:3] toDestination:destination];
}

@end

int main(int argc, const char * argv[]){
    @autoreleasepool {
        MKJavaScriptContext *c = [MKJavaScriptContext new];
        c[@"LPMessage"] = [LPMessage class];

        c.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"%@", exception);
        };
        NSLog(@"%@", [c evaluateScript:[NSString stringWithContentsOfFile:@"/Users/John/Dropbox/Developer/projects/MIDIKit/mktests/test.js" encoding:NSUTF8StringEncoding error:nil]]);


        CFRunLoopRun();
    }

    return 0;
}