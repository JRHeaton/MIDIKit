//
//  LPDev.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKDevice.h"

@interface LPDev : MKDevice

+ (instancetype)firstLaunchpadMiniWithClient:(MKClient *)client;

- (void)sendPadMessageToX:(NSInteger)x y:(NSInteger)y red:(NSInteger)red green:(NSInteger)green copy:(BOOL)copy clear:(BOOL)clear;
- (void)reset;
- (void)testLEDs;

@end
