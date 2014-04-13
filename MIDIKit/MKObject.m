//
//  MKObject.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"
#import <dlfcn.h>
#import <objc/runtime.h>

@implementation MKObject

@synthesize useCaching=_useCaching;
@dynamic valid;

+ (void)load {
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    if(!objc_getClass("MIDINetworkSession")) {
        goto exception;
    }
#else
    if(!dlsym(RTLD_SELF, "MIDIRestart")) {
        goto exception;
    }
#endif

ret: return;

exception:
    [NSException raise:@"MKMissingDependencyException" format:@"CoreMIDI.framework is required to be linked in order for MIDIKit to work"];
}

+ (instancetype)objectWithMIDIRef:(MIDIObjectRef)MIDIRef {
    return [[self alloc] initWithMIDIRef:MIDIRef];
}

+ (instancetype)objectWithUniqueID:(MIDIUniqueID)uniqueID {
    return [[self alloc] initWithUniqueID:uniqueID];
}

- (instancetype)initWithMIDIRef:(MIDIObjectRef)MIDIRef {
    if(!(self = [super init])) return nil;
    
    _MIDIRef = MIDIRef;
    [self commonInit];
    
    return self;
}

- (instancetype)init {
    [NSException raise:NSInvalidArgumentException format:@"You must initialize MKObject with a unique ID or CoreMIDI object"];

    return nil;
}

- (instancetype)initWithUniqueID:(MIDIUniqueID)uniqueID {
    if(!(self = [super init])) return nil;
    
    MIDIObjectType type;
    MIDIObjectFindByUniqueID(uniqueID, &_MIDIRef, &type);
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    self.useCaching = YES;
    _propertyCache = [NSMutableDictionary dictionaryWithCapacity:0];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ valid=%@, properties=%@", super.description, self.valid ? @"YES" : @"NO", self.allProperties];
}

#pragma mark - MIDI Properties

- (NSString *)stringPropertyForKey:(NSString *)key {
    CFStringRef ret;
    NSString *dd;
    if(self.useCaching && (dd = _propertyCache[key]) != nil)
        return dd;
    
    MIDIObjectGetStringProperty(self.MIDIRef, (__bridge CFStringRef)(key), &ret);
    if(ret) _propertyCache[key] = dd = (__bridge_transfer NSString *)(ret);
    return dd;
}

- (NSInteger)integerPropertyForKey:(NSString *)key {
    SInt32 ret;
    NSNumber *dd;
    if(self.useCaching && (dd = _propertyCache[key]) != nil)
        return dd.integerValue;
    
    MIDIObjectGetIntegerProperty(self.MIDIRef, (__bridge CFStringRef)(key), &ret);
    _propertyCache[key] = @(ret);
    return ret;
}

- (NSData *)dataPropertyForKey:(NSString *)key {
    CFDataRef ret;
    NSData *dd;
    if(self.useCaching && (dd = _propertyCache[key]) != nil)
        return dd;
    
    MIDIObjectGetDataProperty(self.MIDIRef, (__bridge CFStringRef)(key), &ret);
    if(ret) _propertyCache[key] = (__bridge NSData *)(ret);
    return (__bridge_transfer NSData *)ret;
}

- (NSDictionary *)dictionaryPropertyForKey:(NSString *)key {
    CFDictionaryRef dict;
    NSDictionary *dd;
    if(self.useCaching && (dd = _propertyCache[key]) != nil)
        return dd;
    
    MIDIObjectGetDictionaryProperty(self.MIDIRef, (__bridge CFStringRef)(key), &dict);
    if(dict) _propertyCache[key] = (__bridge NSDictionary *)(dict);
    return (__bridge_transfer NSDictionary *)dict;
}

- (instancetype)setStringProperty:(NSString *)value forKey:(NSString *)key {
    MIDIObjectSetStringProperty(self.MIDIRef, (__bridge CFStringRef)(key), (__bridge CFStringRef)(value));
    
    _propertyCache[(key)] = value;
    return self;
}

- (instancetype)setIntegerProperty:(NSInteger)value forKey:(NSString *)key {
    MIDIObjectSetIntegerProperty(self.MIDIRef, (__bridge CFStringRef)(key), (SInt32)value);
    _propertyCache[(key)] = @(value);
    return self;
}

- (void)setDataProperty:(NSData *)value forKey:(NSString *)key {
    MIDIObjectSetDataProperty(self.MIDIRef, (__bridge CFStringRef)(key), (__bridge CFDataRef)(value));
    _propertyCache[(key)] = value;
}

- (instancetype)setDictionaryProperty:(NSDictionary *)value forKey:(NSString *)key {
    MIDIObjectSetDictionaryProperty(self.MIDIRef, (__bridge CFStringRef)(key), (__bridge CFDictionaryRef)(value));
    _propertyCache[(key)] = value;
    return self;
}

- (void)removePropertyForKey:(NSString *)key {
    MIDIObjectRemoveProperty(self.MIDIRef, (__bridge CFStringRef)(key));
}

- (BOOL)transmitsOnChannel:(NSUInteger)channel {
    channel = [self channelInRange:channel];
    return (self.transmitChannelBits & (1 << (channel - 1))) >> (channel - 1);
}

- (BOOL)receivesOnChannel:(NSUInteger)channel {
    channel = [self channelInRange:channel];
    return (self.receiveChannelBits & (1 << (channel - 1))) >> (channel - 1);
}

- (instancetype)setTransmits:(BOOL)transmits onChannel:(NSInteger)channel {
    NSUInteger transmitsBits = self.transmitChannelBits;
    channel = [self channelInRange:channel];

    UInt8 bit = (1 << (channel - 1));

    switch ((UInt8)transmits) {
        case YES: transmitsBits |= bit; break;
        case NO: transmitsBits &= ~bit;
    }

    self.transmitChannelBits = transmitsBits;
    return self;
}


#pragma mark - Helpers

- (NSUInteger)channelInRange:(NSUInteger)channel {
    return MIN(MAX(0, channel), 16);
}


#pragma mark - Equality Checking

- (BOOL)isEqual:(id)object {
    if([object isKindOfClass:[MKObject class]]) {
        return self.MIDIRef == ((MKObject *)object).MIDIRef;
    }
    return [super isEqual:object];
}

- (BOOL)isEqualTo:(id)object {
    return [self isEqual:object];
}

- (BOOL)isEqualToObject:(MKObject *)object {
    return [self isEqual:object];
}


#pragma mark - Caching

- (void)performBlockWithCaching:(void (^)(MKObject *obj))block {
    BOOL old = self.useCaching;
    self.useCaching = YES;
    block(self);
    self.useCaching = old;
}

- (instancetype)purgeCache {
    [_propertyCache removeAllObjects];
    return self;
}


#pragma mark - Dynamic Getters/Setters

- (void)setMIDIRef:(MIDIObjectRef)MIDIRef {
    _MIDIRef = MIDIRef;
    [self purgeCache];
}

- (BOOL)isOnline {
    return ![self integerPropertyForKey:(__bridge NSString *)kMIDIPropertyOffline];
}

- (BOOL)isValid {
    return self.MIDIRef != 0;
}

- (NSDictionary *)allProperties {
    CFPropertyListRef ret;
    MIDIObjectGetProperties(self.MIDIRef, &ret, true);
    if(ret) _propertyCache = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(ret)];
    return (__bridge_transfer NSDictionary *)ret;
}


#pragma mark Properties

#define GETTER(type, name, property, propertyType) \
- (type)name { \
return (type)[self propertyType##PropertyForKey:(__bridge NSString *)property]; \
}

#define SETTER(type, name, property, propertyType) \
- (void)set##name:(type)val { \
[self set##propertyType##Property:val forKey:(__bridge NSString *)property]; \
}

SETTER(BOOL, DrumMachine, kMIDIPropertyIsDrumMachine, Integer)
SETTER(BOOL, EffectUnit, kMIDIPropertyIsEffectUnit, Integer)
SETTER(BOOL, isEmbeddedEntity, kMIDIPropertyIsEmbeddedEntity, Integer)
SETTER(BOOL, Mixer, kMIDIPropertyIsMixer, Integer)
SETTER(BOOL, Sampler, kMIDIPropertyIsSampler, Integer)
SETTER(BOOL, Private, kMIDIPropertyPrivate, Integer)

GETTER(BOOL, isDrumMachine, kMIDIPropertyIsDrumMachine, integer)
GETTER(BOOL, isEffectUnit, kMIDIPropertyIsEffectUnit, integer)
GETTER(BOOL, isEmbeddedEntity, kMIDIPropertyIsEmbeddedEntity, integer)
GETTER(BOOL, isMixer, kMIDIPropertyIsMixer, integer)
GETTER(BOOL, isSampler, kMIDIPropertyIsSampler, integer)
GETTER(BOOL, isPrivate, kMIDIPropertyPrivate, integer)

SETTER(NSString *, Manufacturer, kMIDIPropertyManufacturer, String)
SETTER(NSString *, Name, kMIDIPropertyName, String)
SETTER(NSString *, Model, kMIDIPropertyModel, String)
SETTER(NSInteger, DeviceID, kMIDIPropertyDeviceID, Integer)
SETTER(NSString *, DisplayName, kMIDIPropertyDisplayName, String)
SETTER(NSString *, DriverOwner, kMIDIPropertyDriverOwner, String)
SETTER(NSInteger, DriverVersion, kMIDIPropertyDriverVersion, Integer)
SETTER(NSString *, IconImagePath, kMIDIPropertyImage, String)
SETTER(NSInteger, MaxReceiveChannels, kMIDIPropertyMaxReceiveChannels, Integer)
SETTER(NSInteger, MaxSysexSpeed, kMIDIPropertyMaxSysExSpeed, Integer)
SETTER(NSInteger, MaxTransmitChannels, kMIDIPropertyMaxTransmitChannels, Integer)
SETTER(BOOL, PanDisruptsStereo, kMIDIPropertyPanDisruptsStereo, Integer)
SETTER(NSUInteger, ReceiveChannelBits, kMIDIPropertyReceiveChannels, Integer)
SETTER(NSUInteger, TransmitChannelBits, kMIDIPropertyTransmitChannels, Integer)
SETTER(BOOL, ReceivesClock, kMIDIPropertyReceivesClock, Integer)
SETTER(BOOL, ReceivesMTC, kMIDIPropertyReceivesMTC, Integer)
SETTER(BOOL, ReceivesNotes, kMIDIPropertyReceivesNotes, Integer)
SETTER(BOOL, TransmitsMTC, kMIDIPropertyTransmitsMTC, Integer)
SETTER(BOOL, TransmitsClock, kMIDIPropertyTransmitsClock, Integer)
SETTER(BOOL, TransmitsNotes, kMIDIPropertyTransmitsNotes, Integer)
SETTER(BOOL, ReceivesProgramChanges, kMIDIPropertyReceivesProgramChanges, Integer)
SETTER(MIDIUniqueID, UniqueID, kMIDIPropertyUniqueID, Integer)

GETTER(NSString *, manufacturer, kMIDIPropertyManufacturer, string)
GETTER(NSString *, name, kMIDIPropertyName, string)
GETTER(NSString *, model, kMIDIPropertyModel, string)
GETTER(NSInteger, deviceID, kMIDIPropertyDeviceID, integer)
GETTER(NSString *, displayName, kMIDIPropertyDisplayName, string)
GETTER(NSString *, driverOwner, kMIDIPropertyDriverOwner, string)
GETTER(NSInteger, driverVersion, kMIDIPropertyDriverVersion, integer)
GETTER(NSString *, iconImagePath, kMIDIPropertyImage, string)
GETTER(NSInteger, maxReceiveChannels, kMIDIPropertyMaxReceiveChannels, integer)
GETTER(NSInteger, maxSysexSpeed, kMIDIPropertyMaxSysExSpeed, integer)
GETTER(NSInteger, maxTransmitChannels, kMIDIPropertyMaxTransmitChannels, integer)
GETTER(BOOL, panDisruptsStereo, kMIDIPropertyPanDisruptsStereo, integer)
GETTER(NSUInteger, receiveChannelBits, kMIDIPropertyReceiveChannels, integer)
GETTER(NSUInteger, transmitChannelBits, kMIDIPropertyTransmitChannels, integer)
GETTER(BOOL, receivesClock, kMIDIPropertyReceivesClock, integer)
GETTER(BOOL, receivesMTC, kMIDIPropertyReceivesMTC, integer)
GETTER(BOOL, receivesNotes, kMIDIPropertyReceivesNotes, integer)
GETTER(BOOL, transmitsMTC, kMIDIPropertyTransmitsMTC, integer)
GETTER(BOOL, transmitsClock, kMIDIPropertyTransmitsClock, integer)
GETTER(BOOL, transmitsNotes, kMIDIPropertyTransmitsNotes, integer)
GETTER(BOOL, receivesProgramChanges, kMIDIPropertyReceivesProgramChanges, integer)
GETTER(MIDIUniqueID, uniqueID, kMIDIPropertyUniqueID, integer)

#undef GETTER
#undef SETTER

@end
