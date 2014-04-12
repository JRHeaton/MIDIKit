//
//  MKJavaScriptContext.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKJavaScriptContext.h"
#import "MKClient.h"

@implementation MKJavaScriptContext

- (instancetype)init {
    if(!(self = [super init])) return nil;
    
    [self setup];
    
    return self;
}

- (void)setup {
    self[@"console"] = @{ @"log" : ^(NSString *log) { NSLog(@"%@", log); } };
    self[@"client"] = [MKClient clientWithName:@"MKJavaScriptClient"];
    self[@"numberOfDevices"] = ^{ return [MKDevice numberOfDevices]; };
    self[@"numberOfSources"] = ^{ return [MKEndpoint numberOfSources]; };
    self[@"sourceAtIndex"] = ^(NSUInteger index) { return [MKEndpoint sourceAtIndex:index]; };
    self[@"destinationAtIndex"] = ^(NSUInteger index) { return [MKEndpoint destinationAtIndex:index]; };
    self[@"numberOfDestinations"] = ^{ return [MKEndpoint numberOfDestinations]; };
    self[@"firstOnlineDestinationNamed"] = ^(NSString *name) {
        return [MKEndpoint firstOnlineDestinationNamed:name];
    };
    self[@"firstOnlineSourceNamed"] = ^(NSString *name) {
        return [MKEndpoint firstOnlineSourceNamed:name];
    };
    
}

@end
