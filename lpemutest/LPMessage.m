//
//  LPMessage.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "LPMessage.h"

static const UInt8 LPMsg[2][3] = {
    { 0xb0, 0x00, 0x00 }, // RESET
    { 0xb0, 0x00, 0x7f }, // TEST LEDs
};

@implementation LPMessage

+ (instancetype)_staticMessageAtIndex:(NSUInteger)index {
    return [[self alloc] initWithData:[NSData dataWithBytes:LPMsg[index] length:3]];
}

+ (instancetype)reset {
    return [self _staticMessageAtIndex:0];
}

+ (instancetype)LEDTest {
    return [self _staticMessageAtIndex:1];
}

@end
