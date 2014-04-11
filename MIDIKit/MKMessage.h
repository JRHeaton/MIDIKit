//
//  MKMessage.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt8, MKMessageType) {
    kMKMessageTypeNoteOn = 0x90,
    kMKMessageTypeNoteOff = 0x80,
    kMKMessageTypeControlChange = 0xB0
};

@interface MKMessage : NSObject

- (instancetype)initWithData:(NSData *)data;

@property (nonatomic, assign) MKMessageType type;
@property (nonatomic, assign) UInt8 keyOrController;
@property (nonatomic, assign) UInt8 velocityOrValue;

@property (nonatomic, assign) UInt8 channel;

- (NSData *)data;
- (UInt8 *)bytes;
- (NSUInteger)length;
- (void)setByte:(UInt8)byte atIndex:(NSUInteger)index;
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)idx;

@end
