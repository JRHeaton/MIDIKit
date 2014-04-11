//
//  MKInputPort.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKInputPort.h"

@implementation MKInputPort

- (void)connectSource:(MKEndpoint *)source {
    MIDIPortConnectSource(self.MIDIRef, source.MIDIRef, (__bridge void *)(self));
}

- (void)disconnectSource:(MKEndpoint *)source {
    MIDIPortDisconnectSource(self.MIDIRef, source.MIDIRef);
}

@end
