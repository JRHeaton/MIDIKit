//
//  JRSecondModule.h
//  MIDIKit
//
//  Created by John Heaton on 4/13/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIKit.h"

@protocol SecondJS <JSExport>

+ (NSString *)fart;

@end

@interface JRSecondModule : NSObject <MKJavaScriptModule, SecondJS>

@end
