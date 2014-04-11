//
//  MKObject.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

/*
 This is the root wrapper class for CoreMIDI objects.
 
 Its main use is providing easy access to properties of
 objects in native ObjC types, and verifying that objects
 are valid. There is support for caching object properties,
 though this may change in the future. It's on by default,
 but you may set useCaching to NO.
 */
@interface MKObject : NSObject {
@package
    NSMutableDictionary *_propertyCache;
@protected
    MIDIObjectRef _MIDIRef;
}

// Instantiation
- (instancetype)initWithMIDIRef:(MIDIObjectRef)MIDIRef;
- (instancetype)initWithUniqueID:(MIDIUniqueID)uniqueID;

// If YES(default), then as properties are retrieved they are
// cached
@property (nonatomic, assign) BOOL useCaching;

// Turns useCaching on during execution, then back to previous setting
- (void)performBlockWithCaching:(void (^)(MKObject *obj))block;

// Accessing MIDI properties
- (NSString *)stringPropertyForKey:(CFStringRef)key;
- (NSInteger)integerPropertyForKey:(CFStringRef)key;
- (NSData *)dataPropertyForKey:(CFStringRef)key;
- (NSDictionary *)dictionaryPropertyForKey:(CFStringRef)key;

// This will copy the entire dict. This is called in -description,
// but is not recommended for general use. It may be slow.
- (NSDictionary *)allProperties;

// Setting/removing properties
- (void)setStringProperty:(NSString *)value forKey:(CFStringRef)key;
- (void)setIntegerProperty:(NSInteger)value forKey:(CFStringRef)key;
- (void)setDataProperty:(NSData *)value forKey:(CFStringRef)key;
- (void)setDictionaryProperty:(NSDictionary *)value forKey:(CFStringRef)key;
- (void)removePropertyForKey:(CFStringRef)key;

// Properties
@property (nonatomic, readonly, getter = isOnline) BOOL online;
@property (nonatomic, readonly, getter = isDrumMachine) BOOL drumMachine;
@property (nonatomic, readonly, getter = isEffectUnit) BOOL effectUnit;
@property (nonatomic, readonly, getter = isEmbeddedEntity) BOOL embeddedEntity;
@property (nonatomic, readonly, getter = isMixer) BOOL mixer;
@property (nonatomic, readonly, getter = isSampler) BOOL sampler;
@property (nonatomic, readonly) BOOL isPrivate;

// More properties
- (NSString *)manufacturer;
- (NSString *)name;
- (NSString *)model;
- (NSInteger)deviceID;
- (NSString *)displayName;
- (NSString *)driverOwner;
- (NSInteger)driverVersion;
- (NSString *)iconImagePath;
- (NSInteger)maxReceiveChannels;
- (NSInteger)maxSysexSpeed;
- (NSInteger)maxTransmitChannels;
- (BOOL)panDisruptsStereo;
- (NSUInteger)receiveChannelBits;
- (NSUInteger)transmitChannelBits;
- (BOOL)transmitsOnChannel:(NSInteger)channel;
- (BOOL)receivesOnChannel:(NSInteger)channel;
- (BOOL)receivesClock;
- (BOOL)receivesMTC;
- (BOOL)receivesNotes;
- (BOOL)transmitsClock;
- (BOOL)transmitsMTC;
- (BOOL)transmitsNotes;
- (BOOL)receivesProgramChanges;
- (MIDIUniqueID)uniqueID;

// Underlying MIDI object
@property (nonatomic, assign) MIDIObjectRef MIDIRef;

// Whether or not the MIDIRef is junk
@property (nonatomic, readonly, getter = isValid) BOOL valid;

@end
