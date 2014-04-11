//
//  MKObject.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKObject.h"

@implementation MKObject

@dynamic valid;

+ (instancetype)objectForMIDIRef:(MIDIObjectRef)MIDIRef {
    return [[self alloc] initWithMIDIRef:MIDIRef];
}

+ (instancetype)objectForUniqueID:(MIDIUniqueID)uniqueID {
    return [[self alloc] initWithUniqueID:uniqueID];
}

- (instancetype)initWithMIDIRef:(MIDIObjectRef)MIDIRef {
    if(!(self = [super init])) return nil;
    
    _MIDIRef = MIDIRef;
    self.useCaching = YES;
    _propertyCache = [NSMutableDictionary dictionaryWithCapacity:0];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ MIDI Properties=%@", super.description, self.allProperties];
}

- (void)performBlockWithCaching:(void (^)(MKObject *obj))block {
    BOOL old = self.useCaching;
    self.useCaching = YES;
    block(self);
    self.useCaching = old;
}

- (instancetype)initWithUniqueID:(MIDIUniqueID)uniqueID {
    if(!(self = [super init])) return nil;
    
    MIDIObjectType type;
    MIDIObjectFindByUniqueID(uniqueID, &_MIDIRef, &type);
    
    return self;
}

- (NSString *)stringPropertyForKey:(CFStringRef)key {
    CFStringRef ret;
    NSString *dd;
    if(self.useCaching && (dd = _propertyCache[(__bridge NSString *)key]) != nil)
        return dd;
    
    MIDIObjectGetStringProperty(self.MIDIRef, key, &ret);
    if(ret) _propertyCache[(__bridge NSString *)key] = (__bridge NSString *)(ret);
    return (__bridge_transfer NSString *)(ret);
}

- (NSInteger)integerPropertyForKey:(CFStringRef)key {
    SInt32 ret;
    NSNumber *dd;
    if(self.useCaching && (dd = _propertyCache[(__bridge NSString *)key]) != nil)
        return dd.integerValue;
    
    MIDIObjectGetIntegerProperty(self.MIDIRef, key, &ret);
    _propertyCache[(__bridge NSString *)key] = @(ret);
    return ret;
}

- (NSData *)dataPropertyForKey:(CFStringRef)key {
    CFDataRef ret;
    NSData *dd;
    if(self.useCaching && (dd = _propertyCache[(__bridge NSString *)key]) != nil)
        return dd;
    
    MIDIObjectGetDataProperty(self.MIDIRef, key, &ret);
    if(ret) _propertyCache[(__bridge NSString *)key] = (__bridge NSData *)(ret);
    return (__bridge_transfer NSData *)ret;
}

- (NSDictionary *)dictionaryPropertyForKey:(CFStringRef)key {
    CFDictionaryRef dict;
    NSDictionary *dd;
    if(self.useCaching && (dd = _propertyCache[(__bridge NSString *)key]) != nil)
        return dd;
    
    MIDIObjectGetDictionaryProperty(self.MIDIRef, key, &dict);
    if(dict) _propertyCache[(__bridge NSString *)key] = (__bridge NSDictionary *)(dict);
    return (__bridge_transfer NSDictionary *)dict;
}

- (NSDictionary *)allProperties {
    CFPropertyListRef ret;
    MIDIObjectGetProperties(self.MIDIRef, &ret, true);
    if(ret) _propertyCache = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(ret)];
    return (__bridge_transfer NSDictionary *)ret;
}

- (void)setStringProperty:(NSString *)value forKey:(CFStringRef)key {
    MIDIObjectSetStringProperty(self.MIDIRef, key, (__bridge CFStringRef)(value));
    _propertyCache[(__bridge NSString *)(key)] = value;
}

- (void)setIntegerProperty:(NSInteger)value forKey:(CFStringRef)key {
    MIDIObjectSetIntegerProperty(self.MIDIRef, key, (SInt32)value);
    _propertyCache[(__bridge NSString *)(key)] = @(value);
}

- (void)setDataProperty:(NSData *)value forKey:(CFStringRef)key {
    MIDIObjectSetDataProperty(self.MIDIRef, key, (__bridge CFDataRef)(value));
    _propertyCache[(__bridge NSString *)(key)] = value;
}

- (void)setDictionaryProperty:(NSDictionary *)value forKey:(CFStringRef)key {
    MIDIObjectSetDictionaryProperty(self.MIDIRef, key, (__bridge CFDictionaryRef)(value));
    _propertyCache[(__bridge NSString *)(key)] = value;
}

#define GETTER(type, name, property, propertyType) \
    - (type)name { \
        return (type)[self propertyType##PropertyForKey:property]; \
    }

#define SETTA(type, name, property, propertyType) \
    - (void)set##name:(type)val { \
        [self set##propertyType##Property:val forKey:property]; \
    }

- (BOOL)isOnline {
    return ![self integerPropertyForKey:kMIDIPropertyOffline];
}

SETTA(BOOL, DrumMachine, kMIDIPropertyIsDrumMachine, Integer)
SETTA(BOOL, EffectUnit, kMIDIPropertyIsEffectUnit, Integer)
SETTA(BOOL, isEmbeddedEntity, kMIDIPropertyIsEmbeddedEntity, Integer)
SETTA(BOOL, Mixer, kMIDIPropertyIsMixer, Integer)
SETTA(BOOL, Sampler, kMIDIPropertyIsSampler, Integer)
SETTA(BOOL, Private, kMIDIPropertyPrivate, Integer)

GETTER(BOOL, isDrumMachine, kMIDIPropertyIsDrumMachine, integer)
GETTER(BOOL, isEffectUnit, kMIDIPropertyIsEffectUnit, integer)
GETTER(BOOL, isEmbeddedEntity, kMIDIPropertyIsEmbeddedEntity, integer)
GETTER(BOOL, isMixer, kMIDIPropertyIsMixer, integer)
GETTER(BOOL, isSampler, kMIDIPropertyIsSampler, integer)
GETTER(BOOL, isPrivate, kMIDIPropertyPrivate, integer)

SETTA(NSString *, Manufacturer, kMIDIPropertyManufacturer, String)
SETTA(NSString *, Name, kMIDIPropertyName, String)
SETTA(NSString *, Model, kMIDIPropertyModel, String)
SETTA(NSInteger, DeviceID, kMIDIPropertyDeviceID, Integer)
SETTA(NSString *, DisplayName, kMIDIPropertyDisplayName, String)
SETTA(NSString *, DriverOwner, kMIDIPropertyDriverOwner, String)
SETTA(NSInteger, DriverVersion, kMIDIPropertyDriverVersion, Integer)
SETTA(NSString *, IconImagePath, kMIDIPropertyImage, String)
SETTA(NSInteger, MaxReceiveChannels, kMIDIPropertyMaxReceiveChannels, Integer)
SETTA(NSInteger, MaxSysexSpeed, kMIDIPropertyMaxSysExSpeed, Integer)
SETTA(NSInteger, MaxTransmitChannels, kMIDIPropertyMaxTransmitChannels, Integer)
SETTA(BOOL, PanDisruptsStereo, kMIDIPropertyPanDisruptsStereo, Integer)
SETTA(NSUInteger, ReceiveChannelBits, kMIDIPropertyReceiveChannels, Integer)
SETTA(NSUInteger, TransmitChannelBits, kMIDIPropertyTransmitChannels, Integer)
SETTA(BOOL, ReceivesClock, kMIDIPropertyReceivesClock, Integer)
SETTA(BOOL, ReceivesMTC, kMIDIPropertyReceivesMTC, Integer)
SETTA(BOOL, ReceivesNotes, kMIDIPropertyReceivesNotes, Integer)
SETTA(BOOL, TransmitsMTC, kMIDIPropertyTransmitsMTC, Integer)
SETTA(BOOL, TransmitsClock, kMIDIPropertyTransmitsClock, Integer)
SETTA(BOOL, TransmitsNotes, kMIDIPropertyTransmitsNotes, Integer)
SETTA(BOOL, ReceivesProgramChanges, kMIDIPropertyReceivesProgramChanges, Integer)
SETTA(MIDIUniqueID, UniqueID, kMIDIPropertyUniqueID, Integer)

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

- (BOOL)transmitsOnChannel:(NSInteger)channel {
    return (self.transmitChannelBits & (1 << (channel - 1))) >> (channel - 1);
}

- (BOOL)receivesOnChannel:(NSInteger)channel {
    return (self.receiveChannelBits & (1 << (channel - 1))) >> (channel - 1);
}

- (BOOL)isValid {
    return self.MIDIRef != 0;
}

- (void)removePropertyForKey:(CFStringRef)key {
    MIDIObjectRemoveProperty(self.MIDIRef, key);
}

- (BOOL)isEqual:(id)object {
    if([object isKindOfClass:[MKObject class]]) {
        return self.MIDIRef == ((MKObject *)object).MIDIRef;
    }
    return [super isEqual:object];
}

- (void)purgeCache {
    [_propertyCache removeAllObjects];
}

- (void)setMIDIRef:(MIDIObjectRef)MIDIRef {
    _MIDIRef = MIDIRef;
    [self purgeCache];
}

@end
