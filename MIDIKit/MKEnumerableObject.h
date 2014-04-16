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

// NOTE: in the JS version of enumerateWithBlock, we don't have pointers, so
// the block returns a BOOL object, which when yes, stops the loop
//
// MKDevice.enumerateWithBlock(function (object, index) {
//     log(index + ': ' + object.description)
//     return index == 2
// })
JSExportAs(enumerateWithBlock,      + (void)enumerateWithBlockJS:(JSValue *)block);

// MKDevice.firstMeetingCriteria(function (dev) { return dev.name == "Launchpad S" })
JSExportAs(firstMeetingCriteria,    + (instancetype)firstMeetingCriteriaJS:(JSValue *)block);

@end

@interface MKEnumerableObject : MKObject <MKEnumerableObjectJS>

+ (void)enumerateWithBlock:(void (^)(MKEnumerableObject *object, NSUInteger index, BOOL *stop))block;
+ (instancetype)firstMeetingCriteria:(BOOL (^)(MKEnumerableObject *candidate))block;

@end
