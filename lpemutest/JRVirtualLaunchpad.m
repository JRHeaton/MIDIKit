//
//  JRVirtualLaunchpad.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "JRVirtualLaunchpad.h"
#import "LPMessage.h"

@implementation JRVirtualLaunchpad {
    enum ColorLevel {
        Off = 0,
        Min = 1,
        Mid = 2,
        Max = 3
    } ;
    struct PadColor {
        enum ColorLevel red, green;
    };
    enum LayoutMode {
        XY = 1,
        Drum = 2
    };
    struct {
        UInt8 display_buffer:1;
        UInt8 update_buffer:1;
        UInt8 auto_swapping:1;
        UInt8 rapid_updating:1;
        enum LayoutMode layout_mode:1;
        struct {
            UInt8 x:3;
            UInt8 y:3;
        } rapid_cursor;
        struct {
            UInt8 numerator:5;
            UInt8 denominator:5;
        } dimness;
        struct {
            struct PadColor grid[8][8];
            struct PadColor top[8];
            struct PadColor right[8];
        } buffers[2];
    } state;
    
    UInt8 handshake[3];
    UInt8 challenge[4];
}

@synthesize client=_client;

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    if(!(self = [super init])) return nil;
    
    self.client = client;
    vSource = [[MKVirtualSource alloc] initWithName:name client:client];
    vDest = [[MKVirtualDestination alloc] initWithName:name client:client];
    [vDest addDelegate:self];
    
    [self reset];
    
    return self;
}

- (void)reset {
    [self handleMessage:[LPMessage reset]];
}

- (void)handleMessage:(MKMessage *)message {
    [self handleData:message.data];
}

- (void)handleData:(NSData *)midi {
    UInt8 *buf = (UInt8 *)midi.bytes;
    
#define TYPE 0
#define KEY  1
#define VEL  2
#define PURIFY(type) (type & 0xF0)
    
    switch (PURIFY(buf[TYPE])) {
        case 0xb0: { // CC
            switch (buf[KEY]) {
                case 0x00: { // command
                    switch (buf[VEL]) {
                        case 0x00: { // reset
                            bzero(&state, sizeof(state));
                            
                            // This is as it is described in the spec document
                            state.layout_mode = XY;
                            state.dimness.numerator = 1;
                            state.dimness.denominator = 5;
                            
                        } break;
                    } break;
                    
                case 0x10: {
                    // handle component thingy bitch
                    if(!(buf[VEL])) {
                        [vSource receivedData:[NSData dataWithBytes:buf length:3]];
                    } else {
                        memcpy(handshake, buf, 3);
                    }
                } break;
                    
                case 0x11:
                case 0x12:
                case 0x13:
                case 0x14:
                    
                    NSLog(@"on thing");
                    challenge[buf[1]-0x11] = buf[2];
                    if (buf[KEY] == 0x14) {
                        UInt8 buf[8] = { 0xf0, 0, 32, 41, 6, 0x0, 0x0, 0xf7 };
                        UInt16 enc = [self abletonEncryptionChallenge:
                                      + (challenge[0] << 0x00)
                                      + (challenge[1] << 0x08)
                                      + (challenge[2] << 0x10)
                                      + (challenge[3] << 0x18)];
                        buf[5] = enc & 0xff;
                        buf[6] = (enc >> 0x08) & 0xff;
                        
                        NSLog(@"Sending back crypt shit");
                        [vSource receivedData:[NSData dataWithBytes:handshake length:3]];
                        [vSource receivedData:[NSData dataWithBytes:buf length:8]];
                    } break;
                } break;
            }
        }; break;
        case 0x90: { // Note on/off (pad)
            // compute based on layout mode
            
            [self.client.firstOutputPort sendData:midi toDestination:[MKEndpoint firstDestinationMeetingCriteria:^BOOL(MKEndpoint *candidate) {
                return candidate.online && [candidate.name isEqualToString:@"Launchpad Mini 4"];
            }]];
        } break;
        case 0x80: { // Note off (pad)
            
        } break;
        default: break;
    }
}

- (void)virtualDestination:(MKVirtualDestination *)virtualDestination
              receivedData:(NSData *)data {
    
    [self handleData:data];
}

- (UInt16)abletonEncryptionChallenge:(int32_t)rdi {
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

@end
