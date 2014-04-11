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

@interface test : NSObject <MKInputPortDelegate>



@end

@implementation test

- (void)inputPort:(MKInputPort *)inputPort receivedData:(NSData *)data fromSource:(MKEndpoint *)source {
    NSLog(@"Got data of length %lu on port %@ from source %@", data.length, inputPort.name, source.name);
}

@end

int main(int argc, const char * argv[]){
    @autoreleasepool {

        uint8 buf[3] = { 0xb0  , 0, 0 };
        
        MKClient *client = [MKClient clientWithName:@"Johns Client"];
        MKDevice *dev = [MKDevice firstDeviceMeetingCriteria:^BOOL(MKDevice *candidate) {
            return candidate.online && [candidate.name containsString:@"Launchpad"];
        }];
        MKConnection *conn = [MKConnection connectionWithClient:client];
        [conn addDestination:dev.rootDestination];
        
        [conn sendData:[NSData dataWithBytes:buf length:3]];
        
        CFRunLoopRun();
}

    return 0;
}