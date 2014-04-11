//
//  MKObject.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

@interface MKObject : NSObject {
@package
    NSMutableDictionary *_propertyCache;
@protected
    MIDIObjectRef _MIDIRef;
}

- (instancetype)initWithMIDIRef:(MIDIObjectRef)MIDIRef;
- (instancetype)initWithUniqueID:(MIDIUniqueID)uniqueID;

@property (nonatomic, assign) BOOL useCaching;
- (void)performBlockWithCaching:(void (^)(MKObject *obj))block;

- (NSString *)stringPropertyForKey:(CFStringRef)key;
- (NSInteger)integerPropertyForKey:(CFStringRef)key;
- (NSData *)dataPropertyForKey:(CFStringRef)key;
- (NSDictionary *)dictionaryPropertyForKey:(CFStringRef)key;
- (NSDictionary *)allProperties;
- (void)setStringProperty:(NSString *)value forKey:(CFStringRef)key;
- (void)setIntegerProperty:(NSInteger)value forKey:(CFStringRef)key;
- (void)setDataProperty:(NSData *)value forKey:(CFStringRef)key;
- (void)setDictionaryProperty:(NSDictionary *)value forKey:(CFStringRef)key;
- (void)removePropertyForKey:(CFStringRef)key;

@property (nonatomic, readonly, getter = isOnline) BOOL online;
@property (nonatomic, readonly, getter = isDrumMachine) BOOL drumMachine;
@property (nonatomic, readonly, getter = isEffectUnit) BOOL effectUnit;
@property (nonatomic, readonly, getter = isEmbeddedEntity) BOOL embeddedEntity;
@property (nonatomic, readonly, getter = isMixer) BOOL mixer;
@property (nonatomic, readonly, getter = isSampler) BOOL sampler;
@property (nonatomic, readonly) BOOL isPrivate;

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

@property (nonatomic, assign) MIDIObjectRef MIDIRef;
@property (nonatomic, readonly, getter = isValid) BOOL valid;

@end
