//
//  LPMessage.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKMessage.h"

typedef NS_ENUM(UInt8, LPColorBrightness) {
    kLPColorOff = 0, 
    kLPColorMin = 1,
    kLPColorMid = 2,
    kLPColorMax = 3
};

@interface LPMessage : MKMessage

+ (instancetype)reset;
+ (instancetype)LEDTest;
+ (instancetype)setLayoutXY;
+ (instancetype)setLayoutDrumRack;
+ (instancetype)enableAutoSwitching;
+ (instancetype)disableAutoSwitching;
+ (instancetype)bufferMessageWithDisplayBuffer:(NSUInteger)displayBuffer
                                updatingBuffer:(NSUInteger)updatingBuffer
                      copyNewDisplayToUpdating:(BOOL)copyToUpdating;
+ (instancetype)setFirstBuffers;
+ (instancetype)setSecondBuffers;
+ (instancetype)padMessageOn:(BOOL)turnOn
                    atColumn:(NSUInteger)column
                         row:(NSUInteger)row
         clearOtherBufferPad:(BOOL)clearOther
           copyToOtherBuffer:(BOOL)copyToOther
               redBrightness:(LPColorBrightness)redBrightness
             greenBrightness:(LPColorBrightness)greenBrightness;
+ (instancetype)redFullAtX:(NSUInteger)x Y:(NSUInteger)y;
+ (instancetype)greenFullAtX:(NSUInteger)x Y:(NSUInteger)y;
+ (instancetype)greenAtX:(NSUInteger)x Y:(NSUInteger)y brightness:(LPColorBrightness)brightness;
+ (instancetype)redAtX:(NSUInteger)x Y:(NSUInteger)y brightness:(LPColorBrightness)brightness;

// Helper
+ (void)enumerateGrid:(void (^)(UInt8 x, UInt8 y))block;

@end
