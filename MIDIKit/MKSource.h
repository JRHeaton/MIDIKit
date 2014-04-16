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

+ (NSUInteger)numberOfSources;
+ (NSUInteger)count;
+ (NSArray *)all;
+ (NSArray *)allOnline;
+ (NSArray *)allOffline;

JSExportAs(atIndex,                 + (instancetype)sourceAtIndex:(NSUInteger)index);

JSExportAs(firstNamed,              + (instancetype)firstSourceNamed:(NSString *)name);
JSExportAs(firstContaining,         + (instancetype)firstSourceContaining:(NSString *)namePart);
JSExportAs(firstOnlineNamed,        + (instancetype)firstOnlineSourceNamed:(NSString *)name);
JSExportAs(firstOnlineContaining,   + (instancetype)firstOnlineSourceContaining:(NSString *)namePart);
JSExportAs(firstOfflineNamed,       + (instancetype)firstOfflineSourceNamed:(NSString *)name);
JSExportAs(firstOfflineContaining,  + (instancetype)firstOfflineSourceContaining:(NSString *)namePart);

@property (nonatomic, readonly) MKEntity *entity;

@end

@interface MKSource : MKEnumerableObject <MKSourceJS, MKEndpointProperties>

@end
