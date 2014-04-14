//
//  LPMessage.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "LPMessage.h"

static const UInt8 LPMsg[6][3] = {
    { 0xb0, 0x00, 0x00 }, // RESET
    { 0xb0, 0x00, 0x7f }, // TEST LEDs
    { 0xb0, 0x00, 0x01 }, // Layout XY
    { 0xb0, 0x00, 0x02 }, // Layout Drum
    { 0xb0, 0x00, 0x28 }, // Auto switch (flash)
    { 0xb0, 0x00, 0x20 }  // Auto switch disable
};

@implementation LPMessage

- (NSUInteger)row {
    return (self.key / 8);
}

- (NSUInteger)column {
    return (self.key % 8);
}

+ (instancetype)_staticMessageAtIndex:(NSUInteger)index {
    return [[self alloc] initWithData:[NSData dataWithBytes:LPMsg[index] length:3]];
}

+ (instancetype)reset {
    return [self _staticMessageAtIndex:0];
}

+ (instancetype)LEDTest {
    return [self _staticMessageAtIndex:1];
}

+ (instancetype)setLayoutXY {
    return [self _staticMessageAtIndex:2];
}

+ (instancetype)setLayoutDrumRack {
    return [self _staticMessageAtIndex:3];
}

+ (instancetype)enableAutoSwitching {
    return [self _staticMessageAtIndex:4];
}

+ (instancetype)disableAutoSwitching {
    return [self _staticMessageAtIndex:5];
}

+ (instancetype)bufferMessageWithDisplayBuffer:(NSUInteger)displayBuffer
                                updatingBuffer:(NSUInteger)updatingBuffer
                      copyNewDisplayToUpdating:(BOOL)copyToUpdating {
    static UInt8 buf[3] = { 0xb0, 0x00, 0x20 };
    
    buf[2]  = 0x20;
    buf[2] |= (displayBuffer & 0xff);
    buf[2] |= (updatingBuffer & 0xff) << 2;
    buf[2] |= copyToUpdating << 4;
    
    return [[self alloc] initWithData:[NSData dataWithBytes:buf length:3]];
}

+ (instancetype)setFirstBuffers {
    return [self bufferMessageWithDisplayBuffer:0 updatingBuffer:0 copyNewDisplayToUpdating:NO];
}

+ (instancetype)setSecondBuffers {
    return [self bufferMessageWithDisplayBuffer:1 updatingBuffer:1 copyNewDisplayToUpdating:NO];
}

+ (instancetype)padMessageOn:(BOOL)turnOn
                    atColumn:(NSUInteger)column
                         row:(NSUInteger)row
         clearOtherBufferPad:(BOOL)clearOther
           copyToOtherBuffer:(BOOL)copyToOther
               redBrightness:(LPColorBrightness)redBrightness
             greenBrightness:(LPColorBrightness)greenBrightness {
    static UInt8 buf[3] = { 0x90, 0x00, 0x00 };
    
#define lucky8(val) (MAX(0, MIN((val), 7)))
    
    buf[1]  = (0x10 * lucky8(row)) + lucky8(column);
    buf[2]  = (0);
    if(turnOn) {
        buf[2]  = [self velocityForRed:redBrightness green:greenBrightness clear:clearOther copy:copyToOther];
    }
    
    return [[self alloc] initWithData:[NSData dataWithBytes:buf length:3]];
}

+ (instancetype)redFullAtX:(NSUInteger)x Y:(NSUInteger)y {
    return [self padMessageOn:YES atColumn:x row:y clearOtherBufferPad:NO copyToOtherBuffer:NO redBrightness:kLPColorMax greenBrightness:kLPColorOff];
}

+ (instancetype)greenFullAtX:(NSUInteger)x Y:(NSUInteger)y {
    return [self padMessageOn:YES atColumn:x row:y clearOtherBufferPad:NO copyToOtherBuffer:NO redBrightness:kLPColorOff greenBrightness:kLPColorMax];
}

+ (instancetype)greenAtX:(NSUInteger)x Y:(NSUInteger)y brightness:(LPColorBrightness)brightness clear:(BOOL)clear {
    return [self padMessageOn:YES atColumn:x row:y clearOtherBufferPad:clear copyToOtherBuffer:NO redBrightness:kLPColorOff greenBrightness:brightness];
}

+ (instancetype)redAtX:(NSUInteger)x Y:(NSUInteger)y brightness:(LPColorBrightness)brightness clear:(BOOL)clear {
    return [self padMessageOn:YES atColumn:x row:y clearOtherBufferPad:clear copyToOtherBuffer:NO redBrightness:brightness greenBrightness:kLPColorOff];
}

+ (UInt8)velocityForRed:(LPColorBrightness)red green:(LPColorBrightness)green clear:(BOOL)clear copy:(BOOL)copy {
    return ((red & 0x03) | ((green & 0x03) << 5) | (clear << 3) | (copy << 2)) & ~0x40;
}

+ (NSArray *)rapidUpdateMessages:(void (^)(UInt8 index, LPColorBrightness *red, LPColorBrightness *green, BOOL *clear))block {
    if(!block) return nil;
    
    NSMutableArray *ret = [NSMutableArray new];
    for(NSUInteger i=0;i<80;++i) {
        LPColorBrightness r1=0, r2=0, g1=0, g2=0;
        BOOL c1=0, c2=0;
        block(i, &r1, &g1, &c1);
        block(++i, &r2, &g2, &c2);
        
        UInt8 buf[3] = { 0x92, 0, 0 };
        buf[1] = [self velocityForRed:r1 green:g1 clear:c1 copy:NO];
        buf[2] = [self velocityForRed:r2 green:g2 clear:c2 copy:NO];
        
        [ret addObject:[LPMessage messageWithData:[NSData dataWithBytes:buf length:3]]];
    }
    
    return ret;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, row=%lu, column=%lu", super.description, self.row, self.column];
}

// Helper
+ (void)enumerateGrid:(void (^)(UInt8 x, UInt8 y))block {
    if(!block) return;
    
    for(UInt8 x=0;x<8;++x) {
        for(UInt8 y=0;y<8;++y) {
            block(x, y);
        }
    }
}

@end
