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

@class MKJavaScriptContext;
@protocol MKObjectJS <JSExport>

JSExportAs(withUniqueID, + (instancetype)objectWithUniqueID:(MIDIUniqueID)uniqueID);
JSExportAs(withMIDIRef, + (instancetype)objectWithMIDIRef:(MIDIObjectRef)MIDIRef);

- (instancetype)setString:(NSString *)value forProperty:(NSString *)propName;
- (instancetype)setInteger:(NSInteger)value forProperty:(NSString *)propName;
- (instancetype)setDictionary:(NSDictionary *)value forProperty:(NSString *)propName;

- (NSString *)stringForProperty:(NSString *)propName;
- (NSInteger)integerForProperty:(NSString *)propName;
- (NSDictionary *)dictionaryForProperty:(NSString *)propName;

- (instancetype)purgeCache;

// If YES(default), then as properties are retrieved they are
// cached
@property (nonatomic, assign) BOOL useCaching;

// Whether or not the MIDIRef is junk
@property (nonatomic, readonly, getter = isValid) BOOL valid;

- (BOOL)isEqualToObject:(id<MKObjectJS>)object;
- (NSString *)description;

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

- (NSData *)dataForProperty:(NSString *)key;
- (instancetype)setData:(NSData *)value forProperty:(NSString *)propName;

- (instancetype)removeProperty:(NSString *)key;
- (instancetype)removeCachedProperty:(NSString *)key;

// This will copy the entire dict. This is called in -description,
// but is not recommended for general use. It may be slow.
- (NSDictionary *)allProperties;

// Underlying MIDI object
@property (nonatomic, assign) MIDIObjectRef MIDIRef;

@end