//
//  MKServer.m
//  MIDIKit
//
//  Created by John Heaton on 4/15/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKServer.h"
#import <CoreMIDI/CoreMIDI.h>

@implementation MKServer

+ (BOOL)restart {
    return !MIDIRestart();
}

- (instancetype)init {
    [NSException raise:@"MKInstantiationException" format:@"You cannot init this class. Use its class methods for manipulating the MIDI server."];
    return nil;
}

@end
