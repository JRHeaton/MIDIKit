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

@interface Test : NSObject <MKInputPortDelegate>

@end

@implementation Test

- (void)inputPort:(MKInputPort *)inputPort receivedData:(NSData *)data fromSource:(MKEndpoint *)source {
    NSLog(@"%@", [MKMessage messageWithData:data]);
    
    MKMessage *msg = [MKMessage messageWithData:data];
    if(msg.keyOrController == 0x52) {
        [inputPort.client.firstOutputPort sendMessage:[MKMessage :0xb0 :0x00 :0x7f] toDestination:[MKEndpoint firstOnlineDestinationNamed:@"Launchpad Mini 4"]];
    } else if(msg.keyOrController == 0x2a) {
        [inputPort.client.firstOutputPort sendMessage:[MKMessage :0xb0 :0x00 :0x00] toDestination:[MKEndpoint firstOnlineDestinationNamed:@"Launchpad Mini 4"]];

    }
}

@end

int main(int argc, const char * argv[]){
    @autoreleasepool {
        MKJavaScriptContext *c = [MKJavaScriptContext new];
        c[@"LPMessage"] = [LPMessage class];

        NSLog(@"%@", [c evaluateScript:[NSString stringWithContentsOfFile:@"/Users/John/Dropbox/Developer/projects/MIDIKit/mktests/test.js" encoding:NSUTF8StringEncoding error:nil]]);
        
        CFRunLoopRun();
    }

    return 0;
}