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
#pragma mark - -Mutual ObjC/JavaScript-

@protocol MKObjectJS <JSExport>

#pragma mark - -Init-
JSExportAs(withUniqueID, + (instancetype)objectWithUniqueID:(MIDIUniqueID)uniqueID);
JSExportAs(withMIDIRef, + (instancetype)objectWithMIDIRef:(MIDIObjectRef)MIDIRef);

#pragma mark - -Properties-
#pragma mark Setters
- (instancetype)setString:(NSString *)value forProperty:(NSString *)propName;
- (instancetype)setInteger:(NSInteger)value forProperty:(NSString *)propName;
- (instancetype)setDictionary:(NSDictionary *)value forProperty:(NSString *)propName;

#pragma mark Getters
- (NSString *)stringForProperty:(NSString *)propName;
- (NSInteger)integerForProperty:(NSString *)propName;
- (NSDictionary *)dictionaryForProperty:(NSString *)propName;


#pragma mark - -Cache Control-
- (instancetype)purgeCache;

// If YES(default), then as properties are retrieved they are
// cached
@property (nonatomic, assign) BOOL useCaching;


#pragma mark - -Validity & Equality Checking-
// Whether or not the MIDIRef is junk
@property (nonatomic, readonly, getter = isValid) BOOL valid;

- (BOOL)isEqualToObject:(id<MKObjectJS>)object;

@end

/*
 This is the root wrapper class for CoreMIDI objects.
 
 Its main use is providing easy access to properties of
 objects in native ObjC types, and verifying that objects
 are valid. There is support for caching object properties,
 though this may change in the future. It's on by default,
 but you may set useCaching to NO.
 */

#pragma mark - -Base Object Wrapper-
@interface MKObject : NSObject <MKObjectJS> {
@protected
    MIDIObjectRef _MIDIRef;
}

#pragma mark - -Init-
- (instancetype)initWithMIDIRef:(MIDIObjectRef)MIDIRef;
- (instancetype)initWithUniqueID:(MIDIUniqueID)uniqueID;


#pragma mark - -Caching-
// Turns useCaching on during execution, then back to previous setting
- (instancetype)performBlockWithCaching:(void (^)(MKObject *obj))block;


#pragma mark - -Properties-

#pragma mark Getters
- (NSData *)dataForProperty:(NSString *)key;

#pragma mark Setters
- (instancetype)setData:(NSData *)value forProperty:(NSString *)propName;

#pragma mark Removal
- (instancetype)removeProperty:(NSString *)key;
- (instancetype)removeCachedProperty:(NSString *)key;

#pragma mark Copying All Properties
// This will copy the entire dict. This is called in -description,
// but is not recommended for general use. It may be slow.
- (NSDictionary *)allProperties;


#pragma mark - -Wrapped CoreMIDI Object-
// Underlying MIDI object
@property (nonatomic, assign) MIDIObjectRef MIDIRef;

@end