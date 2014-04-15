//
//  MKSource.h
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

@class MKEntity;
@protocol MKSourceJS <JSExport>

+ (NSUInteger)numberOfSources;
+ (NSUInteger)count;

JSExportAs(atIndex, + (instancetype)sourceAtIndex:(NSUInteger)index);

JSExportAs(firstNamed, + (instancetype)firstSourceNamed:(NSString *)name);
JSExportAs(firstContaining, + (instancetype)firstSourceContaining:(NSString *)namePart);

@property (nonatomic, readonly) MKEntity *entity;

@end

@interface MKSource : MKObject <MKSourceJS>

+ (instancetype)enumerateSources:(BOOL (^)(MKSource *source, NSUInteger index, BOOL *stop))block;

@end
