//
//  JRVirtualLaunchpad.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "JRVirtualLaunchpad.h"

@implementation JRVirtualLaunchpad

@synthesize client=_client;

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    if(!(self = [super init])) return nil;
    
    self.client = client;
    vSource = [[MKVirtualSource alloc] initWithName:name client:client];
    vDest = [[MKVirtualDestination alloc] initWithName:name client:client];
    [vDest addDelegate:self];
    
    return self;
}

- (void)virtualDestination:(MKVirtualDestination *)virtualDestination
              receivedData:(NSData *)data {
    NSLog(@"Recevied message: %@", [[MKMessage alloc] initWithData:data]);
}

@end
