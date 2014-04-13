//
//  testNativeModule.m
//  testNativeModule
//
//  Created by John Heaton on 4/13/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "testNativeModule.h"
#import "MKJavaScriptContext.h"

@implementation testNativeModule

+ (JSValue *)requireReturnValue:(MKJavaScriptContext *)ctx {
    return [JSValue valueWithObject:@"Cool Pants" inContext:ctx];
}

+ (void)doThingy {
    NSLog(@"WE DID IT WE DID IT");
}

@end

Class MKModuleClass() {
    return [testNativeModule class];
}