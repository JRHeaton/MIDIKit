//
//  MKSource.h
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEnumerableObject.h"

@class MKEntity;
@protocol MKSourceJS <JSExport, MKObjectJS, MKEnumerableObjectJS>

@property (nonatomic, readonly) MKEntity *entity;

@end

@interface MKSource : MKEnumerableObject <MKSourceJS, MKEndpointProperties>

@end
