//
//  JRNativeBundle.h
//  MIDIKit
//
//  Created by John Heaton on 4/13/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKJavaScriptModule.h"

@protocol JRNativeBundleJS <JSExport>

+ (NSUInteger)someNumber;

@end

@interface JRNativeBundle : NSObject <MKJavaScriptModule, JRNativeBundleJS>

@end
