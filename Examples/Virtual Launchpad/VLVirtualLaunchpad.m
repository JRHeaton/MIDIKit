//
//  VLVirtualLaunchpad.m
//  MIDIKit
//
//  Created by John Heaton on 4/15/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "VLVirtualLaunchpad.h"

typedef enum {
    Off = 0,
    Min = 1,
    Mid = 2,
    Max = 3
} ColorLevel;

typedef struct {
    ColorLevel red, green;
} PadColor;

@implementation VLVirtualLaunchpad {
    MKClient *client;

    struct {
        UInt8 queued_thingy[3];
        UInt8 challenge[4];
    } controlsurface_auth;

    struct {
        UInt8 display_buffer:1;
        UInt8 update_buffer:1;
        UInt8 auto_swapping:1;
        UInt8 rapid_updating:1;
        VLLayoutMode layout_mode:1;
        struct {
            UInt8 x:3;
            UInt8 y:3;
        } rapid_cursor;
        struct {
            UInt8 numerator:5;
            UInt8 denominator:5;
        } dimness;
        struct {
            PadColor grid[8][8];
            PadColor top[8];
            PadColor right[8];
        } buffers[2];
    } state;
}

+ (instancetype)launchpadNamed:(NSString *)name {
    VLVirtualLaunchpad *ret = [self new];

    ret->client = [MKClient clientWithName:name];
    ret->_inputDestination = [MKVirtualDestination virtualDestinationWithName:name client:ret->client];
    ret->_outputSource = [MKVirtualSource virtualSourceWithName:name client:ret->client];
    ret->_inputDestination.online = ret->_outputSource.online = YES;

    [ret->_inputDestination addDelegate:ret];

    return ret;
}

+ (UInt16)abletonChallenge:(SInt32)rdi {
    int rsi = 0, rdx = 0xffffe397, rcx = 0x20, rax = 0;
    do {
        rax = rsi ^ rdx;
        if (rdi < 0x0) {
            rsi = rax;
        }
        if ((rdx >> 0xf & 0x1) != 0x0) {
            rdx = rdx + rdx;
            rdi = rdi ^ 0x1b;
            rdx = rdx ^ 0x1b;
        }
        else {
            rdx = rdx + rdx;
        }
        rdi = rdi + rdi;
        rcx = rcx - 0x1;
    } while (rcx != 0x0);

    return rsi & 0x7f7f;
}

- (void)reset {
    bzero(&state, sizeof(state));
}

- (void)setLayoutMode:(VLLayoutMode)mode {
    state.layout_mode = mode;
}

- (void)virtualDestination:(MKVirtualDestination *)virtualDestination receivedMessage:(MKMessage *)message {
    switch(message.type) {
        case kMKMessageTypeControlChange: {
            switch(message.key) {
                case 0x10: {
                    // handle component thingy bitch
                    if(message.value == 0) {
                        [_outputSource receivedData:message.data];
                    } else {
                        memcpy(controlsurface_auth.queued_thingy, message.bytes, 3);
                    }
                } break;

                case 0x11:
                case 0x12:
                case 0x13:
                case 0x14:

                    controlsurface_auth.challenge[message.key-0x11] = message.value;
                    if (message.key == 0x14) {
                        uint8_t buf[8] = { 0xf0, 0, 32, 41, 6, 0x0, 0x0, 0xf7 };
                        UInt16 enc = [[self class] abletonChallenge:((controlsurface_auth.challenge[0] << 0x00) +
                                                                     (controlsurface_auth.challenge[1] << 0x08) +
                                                                     (controlsurface_auth.challenge[2] << 0x10) +
                                                                     (controlsurface_auth.challenge[3] << 0x18))];
                        buf[5] = enc & 0xff;
                        buf[6] = (enc >> 0x08) & 0xff;

                        [_outputSource receivedData:[NSData dataWithBytes:controlsurface_auth.queued_thingy length:3]];
                        [_outputSource receivedData:[NSData dataWithBytes:buf length:8]];
                    }
                    break;

                case 0: {
                    switch(message.value) {
                        case 0: [self reset]; break;
                        case 1: [self setLayoutMode:kVLLayoutModeXY]; break;
                        case 2: [self setLayoutMode:kVLLayoutModeDrum]; break;
                    }
                } break;
            }
        } break;
        case kMKMessageTypeNoteOn: {
            NSLog(@"NOTE ON");
        } break;
    }
}

@end
