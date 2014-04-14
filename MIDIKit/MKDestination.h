//
//  MKDestination.h
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEndpoint.h"

@protocol MKDestinationJS <JSExport, MKEndpointJS>


@end

@interface MKDestination : MKEndpoint <MKDestinationJS>

@end
