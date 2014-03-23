//
//  MKObject.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

// Base wrapper class for CoreMIDI "object" (really just an integer ID)

@class MKClient;
@interface MKObject : NSObject

// This allows for custom subclassing of different parts of this framework.
// Call it lazy design, but when you start working with 20 different MIDI products,
// each with its own set of proprietary message logic that you want to encapsulate
// into an object, this becomes extremely handy.
//
// How it works:
// 1) Call +registerClass:forCriteria: with a block
// 2) This block gets called each time an object is about to be returned
//    from one of the factory methods in this class or any derivative classes.
// 3) If you return YES, your class is instantiated in place of MKObject
//
// NOTE: Be smart with this. If you're adding a branch to every instantiation of
// a given class, you can slow things down a bit. When possible, register replacement
// classes at the LOWEST possible ancestor of this class.
+ (void)registerClass:(Class)cls forCriteria:(BOOL (^)(MKObject *obj))block;

// Factory methods for this class that bridge from bare CoreMIDI types
+ (instancetype)objectWithMIDIRef:(MIDIObjectRef)ref;
+ (instancetype)objectWithUniqueID:(MIDIUniqueID)uniqueID objectType:(MIDIObjectType *)objectType;

// Properties of different types from the MIDI server.
// Note: not all properties are returned for all data types.
// See MIDIServices.h for what supports what
- (NSString *)stringForProperty:(CFStringRef)property;
- (NSInteger)integerForProperty:(CFStringRef)property;
- (NSData *)dataForProperty:(CFStringRef)property;
- (NSDictionary *)dictionaryForProperty:(CFStringRef)property;

// Complete dictionary of properties
// NOTE: useful for debugging, bug avoid this for performance
// reasons if at all possible
- (NSDictionary *)allProperties;

// Setting this property will allow for using convenience methods whose logic
// belongs to(and is delgated to) the client.
// An excellent example of this is sending data (see: -[MKDevice send...])
@property (nonatomic, assign) MKClient *client;

// This is the wrapped "object"
// You can assign this at any time, so efficient recycling of
// this wrapper class is possible
// NOTE: BE CAREFUL if you are changing this around whilst making
// assumptions about the class if you've hooked with +registerClass:forCriteria:
@property (nonatomic, assign) MIDIObjectRef MIDIRef;

// Checks if the MIDIRef is a non-zero value
@property (nonatomic, readonly, getter = isValid) BOOL valid;

// Convenience methods for kMIDIPropertyName and !kMIDIPropertyOffline
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly, getter = isOnline) BOOL online;

@end
