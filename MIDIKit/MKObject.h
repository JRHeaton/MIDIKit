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

@protocol MKObjectJS <JSExport>

+ (instancetype)objectForUniqueID:(MIDIUniqueID)uniqueID;

// Properties
@property (nonatomic, readonly, getter = isOnline) BOOL online;
@property (nonatomic, readonly, getter = isDrumMachine) BOOL drumMachine;
@property (nonatomic, readonly, getter = isEffectUnit) BOOL effectUnit;
@property (nonatomic, readonly, getter = isEmbeddedEntity) BOOL embeddedEntity;
@property (nonatomic, readonly, getter = isMixer) BOOL mixer;
@property (nonatomic, readonly, getter = isSampler) BOOL sampler;
@property (nonatomic, readonly) BOOL isPrivate;
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *driverOwner;
@property (nonatomic, copy) NSString *iconImagePath;
@property (nonatomic, assign) NSInteger deviceID;
@property (nonatomic, assign) NSInteger driverVersion;
@property (nonatomic, assign) NSInteger maxReceiveChannels;
@property (nonatomic, assign) NSInteger maxSysexSpeed;
@property (nonatomic, assign) NSInteger maxTransmitChannels;
@property (nonatomic, assign) NSUInteger receiveChannelBits;
@property (nonatomic, assign) NSUInteger transmitChannelBits;
@property (nonatomic, assign) BOOL panDisruptsStereo;
@property (nonatomic, assign) BOOL receivesClock;
@property (nonatomic, assign) BOOL receivesMTC;
@property (nonatomic, assign) BOOL receivesNotes;
@property (nonatomic, assign) BOOL transmitsClock;
@property (nonatomic, assign) BOOL transmitsMTC;
@property (nonatomic, assign) BOOL transmitsNotes;
@property (nonatomic, assign) BOOL receivesProgramChanges;
@property (nonatomic, assign) MIDIUniqueID uniqueID;

- (void)purgeCache;

// If YES(default), then as properties are retrieved they are
// cached
@property (nonatomic, assign) BOOL useCaching;

// Whether or not the MIDIRef is junk
@property (nonatomic, readonly, getter = isValid) BOOL valid;

- (BOOL)transmitsOnChannel:(NSInteger)channel;
- (BOOL)receivesOnChannel:(NSInteger)channel;

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
@package
    NSMutableDictionary *_propertyCache;
@protected
    MIDIObjectRef _MIDIRef;
}

// Instantiation
+ (instancetype)objectForMIDIRef:(MIDIObjectRef)MIDIRef;
- (instancetype)initWithMIDIRef:(MIDIObjectRef)MIDIRef;
- (instancetype)initWithUniqueID:(MIDIUniqueID)uniqueID;

// Turns useCaching on during execution, then back to previous setting
- (void)performBlockWithCaching:(void (^)(MKObject *obj))block;

// Accessing MIDI properties
- (NSString *)stringPropertyForKey:(CFStringRef)key;
- (NSInteger)integerPropertyForKey:(CFStringRef)key;
- (NSData *)dataPropertyForKey:(CFStringRef)key;
- (NSDictionary *)dictionaryPropertyForKey:(CFStringRef)key;

// Setting/removing properties
- (void)setStringProperty:(NSString *)value forKey:(CFStringRef)key;
- (void)setIntegerProperty:(NSInteger)value forKey:(CFStringRef)key;
- (void)setDataProperty:(NSData *)value forKey:(CFStringRef)key;
- (void)setDictionaryProperty:(NSDictionary *)value forKey:(CFStringRef)key;
- (void)removePropertyForKey:(CFStringRef)key;

// This will copy the entire dict. This is called in -description,
// but is not recommended for general use. It may be slow.
- (NSDictionary *)allProperties;

// Underlying MIDI object
@property (nonatomic, assign) MIDIObjectRef MIDIRef;

@end