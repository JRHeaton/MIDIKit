//
//  MKEnumerableObject.h
//  MIDIKit
//
//  Created by John Heaton on 4/16/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

@protocol MKEnumerableObjectJS <JSExport>

+ (NSUInteger)count;
+ (NSArray *)all;
+ (NSArray *)allOnline;
+ (NSArray *)allOffline;

+ (instancetype)atIndex:(NSUInteger)index;
JSExportAs(atIndex, + (instancetype)atIndexNumber:(NSNumber *)number);

+ (instancetype)firstNamed:(NSString *)name;
+ (instancetype)firstContaining:(NSString *)namePart;
+ (instancetype)firstOnlineNamed:(NSString *)name;
+ (instancetype)firstOnlineContaining:(NSString *)namePart;
+ (instancetype)firstOfflineNamed:(NSString *)name;
+ (instancetype)firstOfflineContaining:(NSString *)namePart;

@end

@interface MKEnumerableObject : MKObject <MKEnumerableObjectJS>

+ (void)enumerateWithBlock:(void (^)(MKEnumerableObject *object, NSUInteger index, BOOL *stop))block;
+ (instancetype)firstMeetingCriteria:(BOOL (^)(MKEnumerableObject *candidate))block;

@end
