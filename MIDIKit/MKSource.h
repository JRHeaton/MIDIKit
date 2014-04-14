//
//  MKSource.h
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEndpoint.h"

@protocol MKSourceJS <JSExport, MKEndpointJS>

@end

@interface MKSource : MKEndpoint <MKSourceJS>

@end
