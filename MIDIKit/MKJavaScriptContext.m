//
//  MKJavaScriptContext.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKJavaScriptContext.h"
#import "MKClient.h"
#import "MKConnection.h"

@implementation MKJavaScriptContext

- (instancetype)init {
    if(!(self = [super init])) return nil;
    
    [self setup];
    
    return self;
}

- (instancetype)initWithVirtualMachine:(JSVirtualMachine *)virtualMachine {
    if(!(self = [super initWithVirtualMachine:virtualMachine])) return nil;

    [self setup];

    return self;
}

- (void)setup {
    void (^logBlock)(NSString *log) = ^(NSString *log) { NSLog(@"%@", log); };
    void (^logObjectBlock)(JSValue *val) = ^(JSValue *val) { NSLog(@"%@", val.toObject); };

    self[@"console"] = @{ @"log" : logBlock, @"logObject" : logObjectBlock };
    self[@"log"] = logBlock;
    self[@"logObject"] = logObjectBlock;

    for(NSString *className in @[ @"MKObject",
                                  @"MKClient",
                                  @"MKInputPort",
                                  @"MKOutputPort",
                                  @"MKDevice",
                                  @"MKEntity",
                                  @"MKEndpoint",
                                  @"MKVirtualSource",
                                  @"MKVirtualDestination",
                                  @"MKConnection",
                                  @"MKMessage" ]) {
        self[className] = NSClassFromString(className);
    }
}

@end
