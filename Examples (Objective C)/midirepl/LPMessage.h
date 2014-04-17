//
//  LPMessage.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKMessage.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MKJavaScriptContext.h"

typedef NS_ENUM(UInt8, LPColorBrightness) {
    kLPColorOff = 0, 
    kLPColorMin = 1,
    kLPColorMid = 2,
    kLPColorMax = 3
};

@protocol LPMessageJS <JSExport, MKMessageJS>

+ (instancetype)reset;
+ (instancetype)setFirstBuffers;
+ (instancetype)setSecondBuffers;
+ (instancetype)LEDTest;
+ (instancetype)setLayoutXY;
+ (instancetype)setLayoutDrumRack;
+ (instancetype)enableAutoSwitching;
+ (instancetype)disableAutoSwitching;

+ (instancetype)bufferMessageWithDisplayBuffer:(NSUInteger)displayBuffer
                                updatingBuffer:(NSUInteger)updatingBuffer
                      copyNewDisplayToUpdating:(BOOL)copyToUpdating;

+ (instancetype)padMessageOn:(BOOL)turnOn
                    atColumn:(NSUInteger)column
                         row:(NSUInteger)row
         clearOtherBufferPad:(BOOL)clearOther
           copyToOtherBuffer:(BOOL)copyToOther
               redBrightness:(LPColorBrightness)redBrightness
             greenBrightness:(LPColorBrightness)greenBrightness;
+ (instancetype)redFullAtX:(NSUInteger)x Y:(NSUInteger)y;
+ (instancetype)greenFullAtX:(NSUInteger)x Y:(NSUInteger)y;
+ (instancetype)greenAtX:(NSUInteger)x Y:(NSUInteger)y brightness:(LPColorBrightness)brightness clear:(BOOL)clear;
+ (instancetype)redAtX:(NSUInteger)x Y:(NSUInteger)y brightness:(LPColorBrightness)brightness clear:(BOOL)clear;

@property (nonatomic, readonly) NSUInteger row, column;

@end

@interface LPMessage : MKMessage <LPMessageJS>

+ (NSArray *)rapidUpdateMessages:(void (^)(UInt8 index, LPColorBrightness *red, LPColorBrightness *green, BOOL *clear))block;

// Helper
+ (void)enumerateGrid:(void (^)(UInt8 x, UInt8 y))block;

@end
