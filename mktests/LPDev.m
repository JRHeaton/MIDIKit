//
//  LPDev.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "LPDev.h"

@implementation LPDev

- (void)reset {
    [self sendDataArray:@[ @0xb0, @0x00, @0x00 ] toEndpoint:self.rootEndpoint];
}

- (void)testLEDs {
    [self sendDataArray:@[ @0xb0, @0x00, @0x7f ] toEndpoint:self.rootEndpoint];
}

@end
