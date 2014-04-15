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
    NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ valid=%@, MIDIRef=0x%x", [super description], self.valid ? @"YES" : @"NO", (int)self.MIDIRef];
    if([[self class] hasUniqueID]) {
        [desc appendFormat:@", uniqueID=%d", (int)self.uniqueID];
    }
    if([MIDIKit descriptionsIncludeProperties]) {
        [desc appendFormat:@", properties=%@", self.allProperties];
    }

    return desc;
}

#pragma mark - MIDI Properties

#define CACHED_PROP_PROPERTY(upper, lower) \
- (NS##upper *)lower##ForProperty:(NS##upper *)key { \
    CF##upper##Ref cfVal; \
    NS##upper *nsVal; \
    if(self.useCaching && (nsVal = _propertyCache[key]) != nil) \
        return nsVal; \
\
    [MIDIKit evalOSStatus: \
        MIDIObjectGet##upper##Property(self.MIDIRef, (__bridge CFStringRef)(key), &cfVal) \
        name:[NSString stringWithFormat:@"Getting " #lower " property: \'%@\'", key]]; \
\
    if(cfVal) \
        _propertyCache[key] = nsVal = (__bridge NS##upper *)(cfVal); \
\
    return nsVal; \
}

CACHED_PROP_PROPERTY(Dictionary, dictionary)
CACHED_PROP_PROPERTY(String, string)
CACHED_PROP_PROPERTY(Data, data)

#define CACHED_PROP_PROPERTY_BASE(upper, lower, ret) \
- (ret)set##upper:(NS##upper *)value forProperty:(NSString *)key { \
    if(![MIDIKit evalOSStatus: \
        MIDIObjectSet##upper##Property(self.MIDIRef, (__bridge CFStringRef)(key), (__bridge CF##upper##Ref)(value)) \
        name:[NSString stringWithFormat:@"Setting " #lower " property: \'%@\'", key]]) { \
        _propertyCache[(key)] = value; \
    } \


#define END_RET return self; }
#define END return; }

CACHED_PROP_PROPERTY_BASE(String, string, instancetype) END_RET
CACHED_PROP_PROPERTY_BASE(Dictionary, dictionary, instancetype) END_RET
CACHED_PROP_PROPERTY_BASE(Data, data, instancetype) END_RET

#undef CACHED_PROP_PROPERTY_BASE
#undef CACHED_PROP_PROPERTY
#undef END_RET
#undef END

- (NSInteger)integerForProperty:(NSString *)key {
    SInt32 ret;
    NSNumber *dd;
    if(self.useCaching && (dd = _propertyCache[key]) != nil)
        return dd.integerValue;

    if(![MIDIKit evalOSStatus:MIDIObjectGetIntegerProperty(self.MIDIRef, (__bridge CFStringRef)(key), &ret) name:[NSString stringWithFormat:@"Getting integer property: \'%@\'", key]])
        _propertyCache[key] = @(ret);

    return ret;
}

- (NSDictionary *)allProperties {
    CFPropertyListRef ret;
    if([MIDIKit evalOSStatus:MIDIObjectGetProperties(self.MIDIRef, &ret, true) name:@"Copy object properties"] != 0)
        return nil;

    NSDictionary *properties = (__bridge_transfer NSDictionary *)ret;
    if(ret) _propertyCache = [NSMutableDictionary dictionaryWithDictionary:properties];
    return properties;
}

- (instancetype)setInteger:(NSInteger)value forProperty:(NSString *)key {
    if(![MIDIKit evalOSStatus:MIDIObjectSetIntegerProperty(self.MIDIRef, (__bridge CFStringRef)(key), (SInt32)value) name:[NSString stringWithFormat:@"Setting integer property: \'%@\'", key]])
        _propertyCache[(key)] = @(value);
    return self;
}

- (instancetype)removeCachedProperty:(NSString *)key {
    [self.propertyCache removeObjectForKey:key];
    return self;
}

- (instancetype)removeProperty:(NSString *)key {
    [self removeCachedProperty:key];

    [MIDIKit evalOSStatus:MIDIObjectRemoveProperty(self.MIDIRef, (__bridge CFStringRef)(key)) name:[NSString stringWithFormat:@"Removing property: \'%@\'", key]];
    return self;
}


#pragma mark - Property Logic

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


#pragma mark - Dynamic PROPERTYs/PROPERTYs

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

//
// It _REALLY_ sucks that ObjC doesn't have a nice way to let me mutualize these property implementations
// to more classes without having an empty abstract superclass.
//
// For now, these will stay implemented in every MKObject, but only exported to JS/visible publicly to
// the correct classes, via the MKObjectProperties.h protocols.
//

#define BITFIELD_PROP(upper, lower) \
- (instancetype)set##upper:(BOOL)val onChannel:(NSUInteger)channel {\
    NSUInteger bits = self.lower##ChannelBits;\
    channel = [self channelInRange:channel];\
    UInt8 bit = (1 << (channel - 1));\
\
    switch ((UInt8)val) {\
        case YES: bits |= bit; break;\
        case NO: bits &= ~bit;\
    }\
\
    self.lower##ChannelBits = bits;\
    return self;\
} \
\
- (BOOL)lower##sOnChannel:(NSUInteger)channel { \
    channel = [self channelInRange:channel]; \
    channel = MAX(0, channel - 1); \
    return (self.lower##ChannelBits & (1 << (channel - 1))) >> (channel - 1);\
}

BITFIELD_PROP(Receives, receive)
BITFIELD_PROP(Transmits, transmit)


#pragma mark Properties

#define PROPERTY(type, upper, lower, propSymbol, propertyTypeUpper, propertyTypeLower) \
- (type)lower { \
    return (type)[self propertyTypeLower##ForProperty:(__bridge NSString *)propSymbol]; \
} \
\
- (void)set##upper:(type)val { \
    [self set##propertyTypeUpper:val forProperty:(__bridge NSString *)propSymbol]; \
}

PROPERTY(BOOL, DrumMachine, isDrumMachine, kMIDIPropertyIsDrumMachine, Integer, integer)
PROPERTY(BOOL, EffectUnit, isEffectUnit, kMIDIPropertyIsEffectUnit, Integer, integer)
PROPERTY(BOOL, EmbeddedEntity, isEmbeddedEntity, kMIDIPropertyIsEmbeddedEntity, Integer, integer)
PROPERTY(BOOL, Mixer, isMixer, kMIDIPropertyIsMixer, Integer, integer)
PROPERTY(BOOL, Sampler, isSampler, kMIDIPropertyIsSampler, Integer, integer)
PROPERTY(BOOL, Private, isPrivate, kMIDIPropertyPrivate, Integer, integer)

PROPERTY(NSString *, Manufacturer, manufacturer, kMIDIPropertyManufacturer, String, string)
PROPERTY(NSString *, Name, name, kMIDIPropertyName, String, string)
PROPERTY(NSString *, Model, model, kMIDIPropertyModel, String, string)
PROPERTY(NSInteger, DeviceID, deviceID, kMIDIPropertyDeviceID, Integer, integer)
PROPERTY(NSString *, DisplayName, displayName, kMIDIPropertyDisplayName, String, string)
PROPERTY(NSString *, DriverOwner, driverOwner, kMIDIPropertyDriverOwner, String, string)
PROPERTY(NSInteger, DriverVersion, driverVersion, kMIDIPropertyDriverVersion, Integer, integer)
PROPERTY(NSString *, IconImagePath, iconImagePath, kMIDIPropertyImage, String, string)
PROPERTY(NSInteger, MaxReceiveChannels, maxReceiveChannels, kMIDIPropertyMaxReceiveChannels, Integer, integer)
PROPERTY(NSInteger, MaxSysexSpeed, maxSysexSpeed, kMIDIPropertyMaxSysExSpeed, Integer, integer)
PROPERTY(NSInteger, MaxTransmitChannels, maxTransmitChannels, kMIDIPropertyMaxTransmitChannels, Integer, integer)
PROPERTY(BOOL, PanDisruptsStereo, panDisruptsStereo, kMIDIPropertyPanDisruptsStereo, Integer, integer)
PROPERTY(NSUInteger, ReceiveChannelBits, receiveChannelBits, kMIDIPropertyReceiveChannels, Integer, integer)
PROPERTY(NSUInteger, TransmitChannelBits, transmitChannelBits, kMIDIPropertyTransmitChannels, Integer, integer)
PROPERTY(BOOL, ReceivesClock, receivesClock, kMIDIPropertyReceivesClock, Integer, integer)
PROPERTY(BOOL, ReceivesMTC, receivesMTC, kMIDIPropertyReceivesMTC, Integer, integer)
PROPERTY(BOOL, ReceivesNotes, receivesNotes, kMIDIPropertyReceivesNotes, Integer, integer)
PROPERTY(BOOL, TransmitsMTC, transmitsMTC, kMIDIPropertyTransmitsMTC, Integer, integer)
PROPERTY(BOOL, TransmitsClock, transmitsClock, kMIDIPropertyTransmitsClock, Integer, integer)
PROPERTY(BOOL, TransmitsNotes, transmitsNotes, kMIDIPropertyTransmitsNotes, Integer, integer)
PROPERTY(BOOL, ReceivesProgramChanges, receivesProgramChanges, kMIDIPropertyReceivesProgramChanges, Integer, integer)

#undef PROPERTY
#undef PROPERTY
#undef BITFIELD_PROP

@end
