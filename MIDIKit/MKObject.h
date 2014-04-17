//
//  MKObject.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "MKObjectProperties.h"

@class MKJavaScriptContext, MKObject;
@protocol MKObjectJS <JSExport>

+ (instancetype)withUniqueID:(MIDIUniqueID)uniqueID;
+ (instancetype)withMIDIRef:(MIDIObjectRef)MIDIRef;

- (instancetype)setString:(NSString *)value forProperty:(NSString *)propName;
- (instancetype)setDictionary:(NSDictionary *)value forProperty:(NSString *)propName;

// "integer" properties can be many different types
- (instancetype)setUnsignedInteger:(UInt32)value forProperty:(NSString *)propName;
- (instancetype)setInteger:(SInt32)value forProperty:(NSString *)propName;
- (instancetype)setNumber:(NSNumber *)value forProperty:(NSString *)propName;
- (instancetype)setBool:(BOOL)value forProperty:(NSString *)propName;

- (NSString *)stringForProperty:(NSString *)propName;
- (NSDictionary *)dictionaryForProperty:(NSString *)propName;
- (NSNumber *)numberForProperty:(NSString *)propName;

JSExportAs(unsignedIntegerForProperty,  - (JSValue *)unsignedIntegerForPropertyJS:(NSString *)propName);
JSExportAs(integerForProperty,          - (JSValue *)integerForPropertyJS:(NSString *)propName);
JSExportAs(boolForProperty,             - (JSValue *)boolForPropertyJS:(NSString *)propName);

- (instancetype)removeProperty:(NSString *)key;
- (instancetype)removeCachedProperty:(NSString *)key;

- (instancetype)purgeCache;

// This will copy the entire dict. This is called in -description,
// but is not recommended for general use. It may be slow.
@property (nonatomic, readonly) NSDictionary *allProperties;

// If YES(default), then as properties are retrieved they are
// cached
@property (nonatomic, assign) BOOL useCaching;

// Whether or not the MIDIRef is junk
@property (nonatomic, readonly, getter = isValid) BOOL valid;

- (BOOL)isEqualToObject:(MKObject *)object;

// This is for accessing the ObjC description value via JS
@property (nonatomic, readonly) NSString *description;

@end

/*
 This is the root wrapper class for CoreMIDI objects.
 
 Its main use is providing easy access to properties of
 objects in native ObjC types, and verifying that objects
 are valid. There is support for caching object properties,
 though this may change in the future. It's on by default,
 but you may set useCaching to NO.
 */

@interface MKObject : NSObject <MKObjectJS> {
@protected
    MIDIObjectRef _MIDIRef;
}

- (instancetype)initWithMIDIRef:(MIDIObjectRef)MIDIRef;
- (instancetype)initWithUniqueID:(MIDIUniqueID)uniqueID;

// Turns useCaching on during execution, then back to previous setting
- (instancetype)performBlockWithCaching:(void (^)(MKObject *obj))block;

- (instancetype)setData:(NSData *)value forProperty:(NSString *)propName;
- (NSData *)dataForProperty:(NSString *)key;

- (UInt32)unsignedIntegerForProperty:(NSString *)propName exists:(BOOL *)exists;
- (SInt32)integerForProperty:(NSString *)propName exists:(BOOL *)exists;
- (BOOL)boolForProperty:(NSString *)propName exists:(BOOL *)exists;

// Underlying MIDI object
@property (nonatomic, assign) MIDIObjectRef MIDIRef;

@end