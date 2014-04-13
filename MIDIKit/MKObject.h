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
#import "MKJavaScriptModule.h"

@class MKJavaScriptContext;
#pragma mark - -Mutual ObjC/JavaScript-

@protocol MKObjectJS <JSExport, NSObject>

#pragma mark - -Init-
+ (instancetype)objectWithUniqueID:(MIDIUniqueID)uniqueID;

#pragma mark - -Properties-

#pragma mark Identity
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *driverOwner;
@property (nonatomic, assign) MIDIUniqueID uniqueID;
@property (nonatomic, assign) NSInteger deviceID;
@property (nonatomic, assign) NSInteger driverVersion;

#pragma mark Type
@property (nonatomic, assign, getter = isDrumMachine) BOOL drumMachine;
@property (nonatomic, assign, getter = isEffectUnit) BOOL effectUnit;
@property (nonatomic, assign, getter = isEmbeddedEntity) BOOL embeddedEntity;
@property (nonatomic, assign, getter = isMixer) BOOL mixer;
@property (nonatomic, assign, getter = isSampler) BOOL sampler;

#pragma mark State
@property (nonatomic, assign, getter = isOnline) BOOL online;
@property (nonatomic, assign) BOOL isPrivate;

#pragma mark Misc 
@property (nonatomic, copy) NSString *iconImagePath;
@property (nonatomic, assign) BOOL panDisruptsStereo;

#pragma mark Capabilities
@property (nonatomic, assign) NSInteger maxReceiveChannels;
@property (nonatomic, assign) NSInteger maxSysexSpeed;
@property (nonatomic, assign) NSInteger maxTransmitChannels;
@property (nonatomic, assign) NSUInteger receiveChannelBits;
@property (nonatomic, assign) NSUInteger transmitChannelBits;
@property (nonatomic, assign) BOOL receivesClock;
@property (nonatomic, assign) BOOL receivesMTC;
@property (nonatomic, assign) BOOL receivesNotes;
@property (nonatomic, assign) BOOL transmitsClock;
@property (nonatomic, assign) BOOL transmitsMTC;
@property (nonatomic, assign) BOOL transmitsNotes;
@property (nonatomic, assign) BOOL receivesProgramChanges;

#pragma mark Setters
- (instancetype)setStringProperty:(NSString *)value forKey:(NSString *)key;
- (instancetype)setIntegerProperty:(NSInteger)value forKey:(NSString *)key;
- (instancetype)setDictionaryProperty:(NSDictionary *)value forKey:(NSString *)key;

#pragma mark Getters
- (NSString *)stringPropertyForKey:(NSString *)key;
- (NSInteger)integerPropertyForKey:(NSString *)key;
- (NSDictionary *)dictionaryPropertyForKey:(NSString *)key;

#pragma mark Transmission Capabilities
- (BOOL)transmitsOnChannel:(NSUInteger)channel;
- (BOOL)receivesOnChannel:(NSUInteger)channel;
- (instancetype)setTransmits:(BOOL)transmits onChannel:(NSInteger)channel;
- (instancetype)setReceives:(BOOL)receives onChannel:(NSUInteger)channel;


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
@interface MKObject : NSObject <MKObjectJS, MKJavaScriptModule> {
@protected
    MIDIObjectRef _MIDIRef;
}

+ (OSStatus)evalOSStatus:(OSStatus)code name:(NSString *)name throw:(BOOL)throw;

#pragma mark - -Init-
+ (instancetype)objectWithMIDIRef:(MIDIObjectRef)MIDIRef;
- (instancetype)initWithMIDIRef:(MIDIObjectRef)MIDIRef;
- (instancetype)initWithUniqueID:(MIDIUniqueID)uniqueID;


#pragma mark - -Caching-
// Turns useCaching on during execution, then back to previous setting
- (void)performBlockWithCaching:(void (^)(MKObject *obj))block;


#pragma mark - -Properties-

#pragma mark Getters
- (NSData *)dataPropertyForKey:(NSString *)key;

#pragma mark Setters
- (void)setDataProperty:(NSData *)value forKey:(NSString *)key;

#pragma mark Removal
- (void)removePropertyForKey:(NSString *)key;
- (void)removeCachedPropertyForKey:(NSString *)key;

#pragma mark Copying All Properties
// This will copy the entire dict. This is called in -description,
// but is not recommended for general use. It may be slow.
- (NSDictionary *)allProperties;


#pragma mark - -Wrapped CoreMIDI Object-
// Underlying MIDI object
@property (nonatomic, assign) MIDIObjectRef MIDIRef;

@end