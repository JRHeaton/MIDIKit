//
//  LPDev.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "LPDev.h"
#import "MKClient.h"

@implementation LPDev

+ (instancetype)firstLaunchpadMiniWithClient:(MKClient *)client {
    __block LPDev *ret = nil;
    [client enumerateDevicesUsingBlock:^(MKDevice *device) {
        if(device.online && [device isKindOfClass:[LPDev class]]) {
            ret = (LPDev *)device;
        }
    }];

    return ret;
}

- (void)reset {
    [self sendDataArray:@[ @0xb0, @0x00, @0x00 ] toEndpoint:self.rootDestination];
}

- (void)testLEDs {
    [self sendDataArray:@[ @0xb0, @0x00, @0x7f ] toEndpoint:self.rootDestination];
}

- (void)sendPadMessageToX:(NSInteger)x y:(NSInteger)y red:(NSInteger)red green:(NSInteger)green copy:(BOOL)copy clear:(BOOL)clear {
    using u8 = UInt8;
    union PadMsg {
    public:
        PadMsg() {
            st._zero = 0;
        }
        struct {
            unsigned red:2;
            unsigned copy:1;
            unsigned clear:1;
            unsigned green:2;
            unsigned _zero:1;
        } st __attribute__((packed));
        u8 vel;
    };

    PadMsg msg;
    msg.st.red = red & 0xff;
    msg.st.green = green & 0xff;
    msg.st.clear = clear;
    msg.st.copy = copy;

    auto buf = new u8[3];
    buf[0] = 0x90;
    buf[1] = static_cast<u8>(((0x10 * y) + x));
    buf[2] = msg.vel;

    [self sendData:[NSData dataWithBytes:buf length:3] toEndpoint:self.rootDestination];
}

@end
