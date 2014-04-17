//
//  MKObject.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"
#import "MKPrivate.h"
#import <objc/runtime.h>

@interface MKObject ()
@property (nonatomic, strong) NSMutableDictionary *propertyCache;
@end

static NSMapTable *_MKObjectMap = nil;

@implementation MKObject 

@synthesize useCaching=_useCaching;

+ (void)load {
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    if(!objc_getClass("MIDINetworkSession")) {
        goto exception;
    }
#else
    #import <dlfcn.h>

    if(!dlsym(RTLD_SELF, "MIDIRestart")) {
        goto exception;
    }
#endif
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MKObjectMap = [NSMapTable strongToWeakObjectsMapTable];
    });
    
    return;

exception:
    [NSException raise:@"MKMissingDependencyException" format:@"CoreMIDI.framework is required to be linked in order for MIDIKit to work"];
}

+ (instancetype)withMIDIRef:(MIDIObjectRef)MIDIRef {
    return [[self alloc] initWithMIDIRef:MIDIRef];
}

+ (instancetype)withUniqueID:(MIDIUniqueID)uniqueID {
    return [[self alloc] initWithUniqueID:uniqueID];
}

- (instancetype)initWithMIDIRef:(MIDIObjectRef)MIDIRef {
    MKObject *ret;
    if((ret = [_MKObjectMap objectForKey:@((UInt32)MIDIRef)]) != nil) {
        self = ret;
        [self purgeCache];
        return self;
    }
    if(!(self = [super init])) return nil;
    
    self.MIDIRef = MIDIRef;
    [self commonInit];
    
    return self;
}

- (instancetype)initWithUniqueID:(MIDIUniqueID)uniqueID {
    MIDIObjectType type;
    MIDIObjectRef obj;
    if([MIDIKit evalOSStatus:MIDIObjectFindByUniqueID(uniqueID, &obj, &type) name:@"Find by unique id"] != 0) return nil;

    if((self = [_MKObjectMap objectForKey:@((UInt32)obj)]) != nil) {
        [self purgeCache];
        return self;
    }

    if(!(self = [_MKClassForType(type, nil) withMIDIRef:obj]))

    self.MIDIRef = obj;
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
    BOOL valid = self.valid;

    NSMutableString *desc = [NSMutableString stringWithString:[super description]];
    if(valid)
        [desc appendFormat:@" valid=%@", self.valid ? @"YES" : @"NO"];
    else {
        if(!self.MIDIRef) {
            [desc appendString:@" [Invalid]"];
            return desc;
        } else
            [desc appendFormat:@" MIDIRef=%u", (unsigned int)self.MIDIRef];
    }

    BOOL isClient = [self isKindOfClass:[MKClient class]];
    BOOL isEndpoint =
    [self isKindOfClass:[MKDestination class]] ||
    [self isKindOfClass:[MKSource class]] ||
    [self isKindOfClass:[MKVirtualDestination class]] ||
    [self isKindOfClass:[MKVirtualSource class]];
    BOOL isEntity = [self isKindOfClass:[MKEntity class]];
    BOOL isDevice = [self isKindOfClass:[MKDevice class]];

    if(isClient || isEndpoint || isEndpoint || isEntity || isDevice) {
        NSString *name = self.name;
        if(name.length)
            [desc appendFormat:@", name=\'%@\'", name];
    }
    if(isEntity || isEndpoint || isDevice) {
        [desc appendFormat:@", online=%@", [self isOnline] ? @"YES" : @"NO"];
    }
    if([[self class] hasUniqueID]) {
        [desc appendFormat:@", uniqueID=%d", (int)self.uniqueID];
    }
    if([MIDIKit descriptionsIncludeProperties] && self.valid) {
        NSDictionary *properties = self.allProperties;
        if(properties.count)
            [desc appendFormat:@", properties=%@", self.allProperties];
    }

    return desc;
}

#pragma mark - Helpers

- (NSUInteger)channelInRange:(NSUInteger)channel {
    return MIN(MAX(1, channel), 16);
}

#pragma mark - Equality Checking

- (BOOL)isEqual:(id)object {
    if([object isMemberOfClass:[MKObject class]]) {
        return self.MIDIRef == ((MKObject *)object).MIDIRef;
    }
    return NO;
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
    return !self.shouldHaveUniqueID ? 0 : (MIDIUniqueID)[self integerForProperty:(__bridge NSString *)kMIDIPropertyUniqueID exists:nil];
}

- (void)setMIDIRef:(MIDIObjectRef)MIDIRef {
    [_MKObjectMap removeObjectForKey:@((UInt32)_MIDIRef)];
    [_MKObjectMap setObject:self forKey:@((UInt32)MIDIRef)];

    _MIDIRef = MIDIRef;
    [self purgeCache];
}

- (BOOL)isOnline {
    return ![self integerForProperty:(__bridge NSString *)kMIDIPropertyOffline exists:nil]; // don't use !isOffline because integer values return 0 for undefined
}

- (void)setOnline:(BOOL)online {
    [self setOffline:!online];
}

- (void)setOffline:(BOOL)offline {
    [self setInteger:offline forProperty:(__bridge NSString *)kMIDIPropertyOffline];
}

- (BOOL)isOffline {
    return [self integerForProperty:(__bridge NSString *)kMIDIPropertyOffline exists:nil];
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

#define NUM_REDIRECT_SETTER(upper, lower, NSNumberGetter, type) \
- (instancetype)set##upper:(type)value forProperty:(NSString *)propName { \
return [self setNumber:@(value) forProperty:propName]; \
} \
\
- (type)lower##ForProperty:(NSString *)propName exists:(BOOL *)exists { \
NSNumber *ret = [self numberForProperty:propName]; \
if(exists) *exists = (ret != nil); \
return (type)ret.NSNumberGetter; \
}

NUM_REDIRECT_SETTER(UnsignedInteger, unsignedInteger, unsignedIntValue, UInt32)
NUM_REDIRECT_SETTER(Bool, bool, boolValue, BOOL)
NUM_REDIRECT_SETTER(Integer, integer, intValue, SInt32)

- (instancetype)setNumber:(NSNumber *)value forProperty:(NSString *)propName {
    if(![MIDIKit evalOSStatus:MIDIObjectSetIntegerProperty(self.MIDIRef, (__bridge CFStringRef)(propName), value.intValue) name:[NSString stringWithFormat:@"Setting integer property: \'%@\'", propName]])
        _propertyCache[(propName)] = value;
    return self;
}

#define JS_PROP_GETTER(lower, type, JSValueSelFragment) \
- (JSValue *)lower##ForPropertyJS:(NSString *)propName { \
BOOL exists; \
type val = [self lower##ForProperty:propName exists:&exists]; \
return exists ? [JSValue valueWith##JSValueSelFragment:val inContext:[JSContext currentContext]] : [JSValue valueWithUndefinedInContext:[JSContext currentContext]];\
}

JS_PROP_GETTER(unsignedInteger, UInt32, UInt32)
JS_PROP_GETTER(integer, SInt32, Int32)
JS_PROP_GETTER(bool, BOOL, Bool)

- (NSNumber *)numberForProperty:(NSString *)key {
    SInt32 ret;
    NSNumber *dd;
    if(self.useCaching && (dd = _propertyCache[key]) != nil)
        return dd;

    if(![MIDIKit evalOSStatus:MIDIObjectGetIntegerProperty(self.MIDIRef, (__bridge CFStringRef)(key), &ret) name:[NSString stringWithFormat:@"Getting integer property: \'%@\'", key]])
        _propertyCache[key] = dd = @(ret);

    return dd;
}

- (NSDictionary *)allProperties {
    CFPropertyListRef ret;
    if([MIDIKit evalOSStatus:MIDIObjectGetProperties(self.MIDIRef, &ret, true) name:@"Copy object properties"] != 0)
        return nil;

    NSDictionary *properties = (__bridge_transfer NSDictionary *)ret;
    if(ret) _propertyCache = [NSMutableDictionary dictionaryWithDictionary:properties];
    return properties;
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

#define BITFIELD_PROP(upper, lower) \
- (instancetype)set##upper:(BOOL)val onChannel:(NSUInteger)channel {\
    UInt32 bits = self.lower##ChannelBits;\
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

#define PROPERTY(type, upper, lower, propSymbol, propertyTypeUpper, propertyTypeLower, selAdd) \
- (type)lower { \
    return (type)[self propertyTypeLower##ForProperty:(__bridge NSString *)propSymbol selAdd]; \
} \
\
- (void)set##upper:(type)val { \
    [self set##propertyTypeUpper:val forProperty:(__bridge NSString *)propSymbol]; \
}

#define EPROPERTY(type, upper, lower, propSymbol, propertyTypeUpper, propertyTypeLower) PROPERTY(type, upper, lower, propSymbol, propertyTypeUpper, propertyTypeLower, exists:nil)

EPROPERTY(UInt32,       advanceScheduleTimeMuSec,   advanceScheduleTimeMuSec,   kMIDIPropertyAdvanceScheduleTimeMuSec,  UnsignedInteger,    unsignedInteger)
EPROPERTY(UInt32,       connectionUniqueID,         connectionUniqueID,         kMIDIPropertyConnectionUniqueID,        UnsignedInteger,    unsignedInteger)
EPROPERTY(UInt32,       ReceiveChannelBits,         receiveChannelBits,         kMIDIPropertyReceiveChannels,           Integer,            integer)
EPROPERTY(UInt32,       TransmitChannelBits,        transmitChannelBits,        kMIDIPropertyTransmitChannels,          Integer,            integer)
EPROPERTY(UInt32,       MaxReceiveChannels,         maxReceiveChannels,         kMIDIPropertyMaxReceiveChannels,        Integer,            integer)
EPROPERTY(UInt32,       MaxSysexSpeed,              maxSysexSpeed,              kMIDIPropertyMaxSysExSpeed,             Integer,            integer)
EPROPERTY(UInt32,       MaxTransmitChannels,        maxTransmitChannels,        kMIDIPropertyMaxTransmitChannels,       Integer,            integer)

EPROPERTY(SInt32,       SingleRealtimeEntity,       singleRealtimeEntity,       kMIDIPropertySingleRealtimeEntity,      Integer,            integer)
EPROPERTY(SInt32,       DeviceID,                   deviceID,                   kMIDIPropertyDeviceID,                  Integer,            integer)
EPROPERTY(SInt32,       DriverVersion,              driverVersion,              kMIDIPropertyDriverVersion,             Integer,            integer)

#define CPROPERTY(type, upper, lower, propSymbol, propertyTypeUpper, propertyTypeLower) PROPERTY(type, upper, lower, propSymbol, propertyTypeUpper, propertyTypeLower, )

CPROPERTY(NSString *,   Manufacturer,               manufacturer,               kMIDIPropertyManufacturer,              String,             string)
CPROPERTY(NSString *,   Name,                       name,                       kMIDIPropertyName,                      String,             string)
CPROPERTY(NSString *,   Model,                      model,                      kMIDIPropertyModel,                     String,             string)
CPROPERTY(NSString *,   DisplayName,                displayName,                kMIDIPropertyDisplayName,               String,             string)
CPROPERTY(NSString *,   DriverOwner,                driverOwner,                kMIDIPropertyDriverOwner,               String,             string)
CPROPERTY(NSString *,   IconImagePath,              iconImagePath,              kMIDIPropertyImage,                     String,             string)
CPROPERTY(NSString *,   DriverDeviceEditorApp,      driverDeviceEditorApp,      kMIDIPropertyDriverDeviceEditorApp,     String,             string)

// because the preprocessor can't fucking do ##bool (turns it into _Bool
- (BOOL)_BoolForProperty:(NSString *)propName exists:(BOOL *)exists {
    return [self boolForProperty:propName exists:exists];
}

EPROPERTY(BOOL,         Broadcast,                  isBroadcast,                kMIDIPropertyIsBroadcast,               Bool,               bool)
EPROPERTY(BOOL,         SupportsGeneralMIDI,        supportsGeneralMIDI,        kMIDIPropertySupportsGeneralMIDI,       Integer,            bool)
EPROPERTY(BOOL,         SupportsMMC,                supportsMMC,                kMIDIPropertySupportsMMC,               Integer,            bool)
EPROPERTY(BOOL,         CanRoute,                   canRoute,                   kMIDIPropertyCanRoute,                  Integer,            bool)
EPROPERTY(BOOL,         TransmitsBankSelectMSB,     transmitsBankSelectMSB,     kMIDIPropertyTransmitsBankSelectMSB,    Integer,            bool)
EPROPERTY(BOOL,         TransmitsBankSelectLSB,     transmitsBankSelectLSB,     kMIDIPropertyTransmitsBankSelectLSB,    Integer,            bool)
EPROPERTY(BOOL,         DrumMachine,                isDrumMachine,              kMIDIPropertyIsDrumMachine,             Integer,            bool)
EPROPERTY(BOOL,         EffectUnit,                 isEffectUnit,               kMIDIPropertyIsEffectUnit,              Integer,            bool)
EPROPERTY(BOOL,         EmbeddedEntity,             isEmbeddedEntity,           kMIDIPropertyIsEmbeddedEntity,          Integer,            bool)
EPROPERTY(BOOL,         Mixer,                      isMixer,                    kMIDIPropertyIsMixer,                   Integer,            bool)
EPROPERTY(BOOL,         Sampler,                    isSampler,                  kMIDIPropertyIsSampler,                 Integer,            bool)
EPROPERTY(BOOL,         Private,                    isPrivate,                  kMIDIPropertyPrivate,                   Integer,            bool)
EPROPERTY(BOOL,         PanDisruptsStereo,          panDisruptsStereo,          kMIDIPropertyPanDisruptsStereo,         Integer,            bool)
EPROPERTY(BOOL,         ReceivesClock,              receivesClock,              kMIDIPropertyReceivesClock,             Integer,            bool)
EPROPERTY(BOOL,         ReceivesMTC,                receivesMTC,                kMIDIPropertyReceivesMTC,               Integer,            bool)
EPROPERTY(BOOL,         ReceivesNotes,              receivesNotes,              kMIDIPropertyReceivesNotes,             Integer,            bool)
EPROPERTY(BOOL,         TransmitsMTC,               transmitsMTC,               kMIDIPropertyTransmitsMTC,              Integer,            bool)
EPROPERTY(BOOL,         TransmitsClock,             transmitsClock,             kMIDIPropertyTransmitsClock,            Integer,            bool)
EPROPERTY(BOOL,         TransmitsNotes,             transmitsNotes,             kMIDIPropertyTransmitsNotes,            Integer,            bool)
EPROPERTY(BOOL,         ReceivesProgramChanges,     receivesProgramChanges,     kMIDIPropertyReceivesProgramChanges,    Integer,            bool)


#undef PROPERTY
#undef PROPERTY
#undef BITFIELD_PROP

@end
