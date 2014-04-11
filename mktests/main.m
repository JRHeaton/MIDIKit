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
#import "LPMessage.h"


#import <JavaScriptCore/JavaScriptCore.h>
#import "NSString+JRExtensions.h"
MKConnection *conn;

@interface test : NSObject <MKInputPortDelegate>



@end

@implementation test

- (void)loggy {
    NSLog(@"dsf");
}

- (void)inputPort:(MKInputPort *)inputPort receivedData:(NSData *)data fromSource:(MKEndpoint *)source {
    MKMessage *msg = [[MKMessage alloc] initWithData:data];
    NSLog(@"%@", msg);
    
    [inputPort.client.firstOutputPort sendData:data toDestination:[MKEndpoint firstDestinationMeetingCriteria:^BOOL(MKEndpoint *candidate) {
        return [candidate.name containsString:@"Launchpad Mini"];
    }]];
}

@end

int main(int argc, const char * argv[]){
    @autoreleasepool {

        uint8 buf[3] = { 0xb0  , 0, 0 };
        
        MKClient *client = [MKClient clientWithName:@"Johns Client"];
        MKConnection *connection = [MKConnection connectionWithClient:client];
        [connection addDestination:[MKEndpoint firstDestinationMeetingCriteria:^BOOL(MKEndpoint *candidate) {
            return candidate.online && [candidate.name containsString:@"Launchpad Mini"];
        }]];
        
        [LPMessage enumerateGrid:^(UInt8 x, UInt8 y) {
            [connection sendMessage:[LPMessage redFullAtX:x Y:y]];
        }];
        
        [connection performBlock:^(MKConnection *c) {
            [connection sendMessage:[LPMessage reset]];
        } afterDelay:2];
        
        CFRunLoopRun();
}

    return 0;
}