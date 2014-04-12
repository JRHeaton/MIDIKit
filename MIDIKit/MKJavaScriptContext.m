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

- (void)setup {
    self[@"console"] = @{ @"log" : ^(NSString *log) { NSLog(@"%@", log); } };

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
