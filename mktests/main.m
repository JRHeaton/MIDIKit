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
        MKClient *c = [MKClient new];
        [c.firstInputPort addInputDelegate:[Test new]];
        
        MKEndpoint *mpk = [MKEndpoint firstSourceMeetingCriteria:^BOOL(MKEndpoint *candidate) {
            return candidate.online && [candidate.name containsString:@"MPK"];
        }];
        [c.firstInputPort connectSource:mpk];
        
        CFRunLoopRun();
    }

    return 0;
}