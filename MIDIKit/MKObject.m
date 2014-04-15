//
//  MKObject.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"
#import <dlfcn.h>
#import <objc/runtime.h>

@interface MKObject ()
@property (nonatomic, strong) NSMutableDictionary *propertyCache;
@end

@implementation MKObject

@synthesize useCaching=_useCaching;
@dynamic valid, online, isPrivate, embeddedEntity;

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

- (instancetype)initWithUniqueID:(MIDIUniqueID)uniqueID {
    if(!(self = [super init])) return nil;

    MIDIObjectType type;
    MIDIObjectFindByUniqueID(uniqueID, &_MIDIRef, &type);
    [self commonInit];

    return self;
}

- (instancetype)init {
    [NSException raise:NSInvalidArgumentException format:@"You must initialize MKObject with a unique ID or CoreMIDI object"];

    return nil;
}

- (void)commonInit {
    self.useCaching = YES;
    _propertyCache = [NSMutableDictionary dictionaryWithCapacity:0];

    // global
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(propertyWasUpdated:) name:MKObjectPropertyChangedNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)propertyWasUpdated:(NSNotification *)notif {
    NSString *propertyName = notif.userInfo[MKUserInfoPropertyNameKey];

    [self removeCachedProperty:propertyName];
}

- (NSString *)description {
    if([JSContext currentContext])
        NSLog(@"%@", [JSContext currentContext]);

    NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ valid=%@, MIDIRef=0x%x", [super description], self.valid ? @"YES" : @"NO", self.MIDIRef];
    if([[self class] hasUniqueID]) {
        [desc appendFormat:@", uniqueID=0x%x", self.uniqueID];
    }
    if([MIDIKit descriptionsIncludeProperties]) {
        [desc appendFormat:@", properties=%@", self.allProperties];
    }

    return desc;
}

#pragma mark - MIDI Properties

#define CACHED_PROP_GETTER(upper, lower) \
- (NS##upper *)lower##ForProperty:(NS##upper *)key { \
    CF##upper##Ref cfVal; \
    NS##upper *nsVal; \
    if(self.useCaching && (nsVal = _propertyCache[key]) != nil) \
        return nsVal; \
\
    [MIDIKit evalOSStatus: \
        MIDIObjectGet##upper##Property(self.MIDIRef, (__bridge CFStringRef)(key), &cfVal) \
        name:[NSString stringWithFormat:@"Getting " #lower " property: \'%@\'", key] \
        throw:NO]; \
\
    if(cfVal) \
        _propertyCache[key] = nsVal = (__bridge NS##upper *)(cfVal); \
\
    return nsVal; \
}

CACHED_PROP_GETTER(Dictionary, dictionary)
CACHED_PROP_GETTER(String, string)
CACHED_PROP_GETTER(Data, data)

#define CACHED_PROP_SETTER_BASE(upper, lower, ret) \
- (ret)set##upper:(NS##upper *)value forProperty:(NSString *)key { \
    [MIDIKit evalOSStatus: \
        MIDIObjectSet##upper##Property(self.MIDIRef, (__bridge CFStringRef)(key), (__bridge CF##upper##Ref)(value)) \
        name:[NSString stringWithFormat:@"Setting " #lower " property: \'%@\'", key] \
        throw:NO]; \
\
    _propertyCache[(key)] = value;

#define END_RET return self; }
#define END return; }

CACHED_PROP_SETTER_BASE(String, string, instancetype) END_RET
CACHED_PROP_SETTER_BASE(Dictionary, dictionary, instancetype) END_RET
CACHED_PROP_SETTER_BASE(Data, data, instancetype) END_RET

#undef CACHED_PROP_SETTER_BASE
#undef CACHED_PROP_GETTER
#undef END_RET
#undef END

- (NSInteger)integerForProperty:(NSString *)key {
    SInt32 ret;
    NSNumber *dd;
    if(self.useCaching && (dd = _propertyCache[key]) != nil)
        return dd.integerValue;

    if(![MIDIKit evalOSStatus:MIDIObjectGetIntegerProperty(self.MIDIRef, (__bridge CFStringRef)(key), &ret) name:[NSString stringWithFormat:@"Getting integer property: \'%@\'", key] throw:NO])
        _propertyCache[key] = @(ret);

    return ret;
}

- (instancetype)setInteger:(NSInteger)value forProperty:(NSString *)key {
    if(![MIDIKit evalOSStatus:MIDIObjectSetIntegerProperty(self.MIDIRef, (__bridge CFStringRef)(key), (SInt32)value) name:[NSString stringWithFormat:@"Setting integer property: \'%@\'", key] throw:NO])
        _propertyCache[(key)] = @(value);
    return self;
}

- (instancetype)removeCachedProperty:(NSString *)key {
    [self.propertyCache removeObjectForKey:key];
    return self;
}

- (instancetype)removeProperty:(NSString *)key {
    [self removeCachedProperty:key];

    [MIDIKit evalOSStatus:MIDIObjectRemoveProperty(self.MIDIRef, (__bridge CFStringRef)(key)) name:[NSString stringWithFormat:@"Removing property: \'%@\'", key] throw:NO];
    return self;
}


#pragma mark - Property Logic

- (BOOL)transmitsOnChannel:(NSUInteger)channel {
    channel = [self channelInRange:channel];
    return (self.transmitChannelBits & (1 << (channel - 1))) >> (channel - 1);
}

- (BOOL)receivesOnChannel:(NSUInteger)channel {
    channel = [self channelInRange:channel];
    return (self.receiveChannelBits & (1 << (channel - 1))) >> (channel - 1);
}

- (instancetype)setReceives:(BOOL)receives onChannel:(NSUInteger)channel {
    NSUInteger receivesBits = self.receiveChannelBits;
    channel = [self channelInRange:channel];

    UInt8 bit = (1 << (channel - 1));

    switch ((UInt8)receives) {
        case YES: receivesBits |= bit; break;
        case NO: receivesBits &= ~bit;
    }

    self.receiveChannelBits = receivesBits;
    return self;
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

- (instancetype)performBlockWithCaching:(void (^)(MKObject *obj))block {
    BOOL old = self.useCaching;
    self.useCaching = YES;
    block(self);
    self.useCaching = old;

    return self;
}

- (instancetype)purgeCache {
    [_propertyCache removeAllObjects];
    return self;
}


#pragma mark - Dynamic Getters/Setters

- (void)setUniqueID:(MIDIUniqueID)uniqueID {
    if(self.shouldHaveUniqueID) {
        [self setInteger:uniqueID forProperty:(__bridge NSString *)kMIDIPropertyUniqueID];
    }
}

- (MIDIUniqueID)uniqueID {
    return (MIDIUniqueID)[self integerForProperty:(__bridge NSString *)kMIDIPropertyUniqueID];
}

- (void)setMIDIRef:(MIDIObjectRef)MIDIRef {
    _MIDIRef = MIDIRef;
    [self purgeCache];
}

- (BOOL)isOnline {
    return ![self integerForProperty:(__bridge NSString *)kMIDIPropertyOffline];
}

- (void)setOnline:(BOOL)online {
    [self setInteger:!online forProperty:(__bridge NSString *)kMIDIPropertyOffline];
}

- (BOOL)shouldHaveUniqueID {
    return [[self class] hasUniqueID];
}

+ (BOOL)hasUniqueID {
    return NO; // only entities, endpoints, devices
}

- (BOOL)isValid {
    BOOL valid = self.MIDIRef != 0;
    if([[self class] hasUniqueID]) {
        valid = valid && self.uniqueID != kMIDIInvalidUniqueID; // only these types have one
    }

    return valid;
}

- (NSDictionary *)allProperties {
    CFPropertyListRef ret;
    if([MIDIKit evalOSStatus:MIDIObjectGetProperties(self.MIDIRef, &ret, true) name:@"Copy object properties" throw:NO] != 0)
        return nil;
    
    NSDictionary *properties = (__bridge_transfer NSDictionary *)ret;
    if(ret) _propertyCache = [NSMutableDictionary dictionaryWithDictionary:properties];
    return properties;
}


#pragma mark Properties

#define GETTER(type, name, property, propertyType) \
- (type)name { \
    return (type)[self propertyType##ForProperty:(__bridge NSString *)property]; \
}

#define SETTER(type, name, property, propertyType) \
- (void)set##name:(type)val { \
    [self set##propertyType:val forProperty:(__bridge NSString *)property]; \
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

#undef GETTER
#undef SETTER

@end
