//
//  MKJavaScriptModule.h
//  MIDIKit
//
//  Created by John Heaton on 4/13/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class MKJavaScriptContext;
@protocol MKJavaScriptModule <NSObject>

@optional
+ (NSArray *)classesToLoad:(MKJavaScriptContext *)context;
+ (JSValue *)requireReturnValue:(MKJavaScriptContext *)context;

@end
