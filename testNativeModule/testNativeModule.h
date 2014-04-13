//
//  testNativeModule.h
//  testNativeModule
//
//  Created by John Heaton on 4/13/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKJavaScriptModule.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol testNativeJS <JSExport>

+ (void)doThingy;

@end

@interface testNativeModule : NSObject <MKJavaScriptModule, testNativeJS>

@end
