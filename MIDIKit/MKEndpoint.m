//
//  MKEndpoint.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEndpoint.h"
#import "MKEntity.h"

@implementation MKEndpoint

- (MKEntity *)entity {
    MIDIEntityRef ret;
    if(!MIDIEndpointGetEntity(self.MIDIRef, &ret))
        return [[MKEntity alloc] initWithMIDIRef:ret];
    
    return nil;
}

@end
