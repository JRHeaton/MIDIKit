//
//  MKEnumerableObject.m
//  MIDIKit
//
//  Created by John Heaton on 4/16/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKEnumerableObject.h"
#import "MIDIKit.h"

@implementation MKEnumerableObject

+ (NSArray *)supportedSubClasses {
    static NSArray *ret = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ret = @[ [MKDestination class], [MKSource class], [MKDevice class] ];
    });
    return ret;
}

- (instancetype)init {
    [NSException raise:@"MKEnumerableObjectInvalidAllocationException" format:@"You mustn't allocate this base class directly."];
    return nil;
}

- (instancetype)initWithMIDIRef:(MIDIObjectRef)MIDIRef {
    NSArray *allowed;
    if(![(allowed = [MKEnumerableObject supportedSubClasses]) containsObject:[self class]]) {
        [NSException raise:@"MKEnumerableObjectInvalidSubclassException" format:@"Subclass %@ not found in supported subclasses: %@", NSStringFromClass([self class]), allowed];
    }
    return [super initWithMIDIRef:MIDIRef];
}

// Subclasses
+ (NSUInteger)count { return 0; }
+ (instancetype)atIndex:(NSUInteger)index { return nil; }
// ------------------------------


+ (instancetype)atIndexNumber:(NSNumber *)number {
    return [self atIndex:number.integerValue];
}

+ (NSArray *)all {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateWithBlock:^(MKEnumerableObject *candidate, NSUInteger index, BOOL *stop) {
        [ret addObject:candidate];
    }];
    return ret;
}

+ (NSArray *)allOnline {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateWithBlock:^void(MKEnumerableObject *candidate, NSUInteger index, BOOL *stop) {
        if([(id)candidate isOnline])
            [ret addObject:candidate];
    }];
    return ret;
}

+ (NSArray *)allOffline {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateWithBlock:^void(MKEnumerableObject *candidate, NSUInteger index, BOOL *stop) {
        if([(id)candidate isOffline])
            [ret addObject:candidate];
    }];
    return ret;
}

+ (instancetype)firstNamed:(NSString *)name {
    return [self firstMeetingCriteria:^BOOL(MKEnumerableObject *candidate) {
        return [[(id)candidate name] isEqualToString:name];
    }];
}

+ (instancetype)firstContaining:(NSString *)namePart {
    return [self firstMeetingCriteria:^BOOL(MKEnumerableObject *candidate) {
        return [[(id)candidate name] rangeOfString:namePart].location != NSNotFound;
    }];
}

+ (instancetype)firstOnlineNamed:(NSString *)name {
    return [self firstMeetingCriteria:^BOOL(MKEnumerableObject *candidate) {
        return [(id)candidate isOnline] && [[(id)candidate name] isEqualToString:name];
    }];
}

+ (instancetype)firstOnlineContaining:(NSString *)namePart {
    return [self firstMeetingCriteria:^BOOL(MKEnumerableObject *candidate) {
        return [(id)candidate isOnline] && [[(id)candidate name] rangeOfString:namePart].location != NSNotFound;
    }];
}

+ (instancetype)firstOfflineNamed:(NSString *)name {
    return [self firstMeetingCriteria:^BOOL(MKEnumerableObject *candidate) {
        return [(id)candidate isOffline] && [[(id)candidate name] isEqualToString:name];
    }];
}

+ (instancetype)firstOfflineContaining:(NSString *)namePart {
    return [self firstMeetingCriteria:^BOOL(MKEnumerableObject *candidate) {
        return [(id)candidate isOffline] && [[(id)candidate name] rangeOfString:namePart].location != NSNotFound;
    }];
}

+ (void)enumerateWithBlock:(void (^)(MKEnumerableObject *object, NSUInteger index, BOOL *stop))block {
    if(!block) return;

    BOOL stop = NO;
    for(NSInteger i=0;i<[self count] && !stop;++i) {
        MKEnumerableObject *candidate = [self atIndex:i];
        block(candidate, i, &stop);
    }
}

+ (instancetype)firstMeetingCriteria:(BOOL (^)(MKEnumerableObject *candidate))block {
    for(NSInteger i=0;i<[self count];++i) {
        MKEnumerableObject *candidate = [self atIndex:i];
        if(block(candidate))
            return candidate;
    }

    return nil;
}

+ (void)enumerateWithBlockJS:(JSValue *)block {
    if(!block || block.isNull || block.isUndefined) return; // TODO: print this?

    [self enumerateWithBlock:^(MKEnumerableObject *object, NSUInteger index, BOOL *stop) {
        *stop = [block callWithArguments:@[ object, @(index) ]].toBool;
    }];
}

+ (instancetype)firstMeetingCriteriaJS:(JSValue *)block {
    return [self firstMeetingCriteria:^BOOL(MKEnumerableObject *candidate) {
        return [block callWithArguments:@[ candidate ]].toBool;
    }];
}

@end
