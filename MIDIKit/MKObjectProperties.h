//
//  MKObjectProperties.h
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

#define MKProperty(name, propertyType, type) @property (nonatomic, propertyType) type name;

#define MKStringProperty(name) MKProperty(name, copy, NSString *)
#define MKIntegerProperty(name) MKProperty(name, assign, NSInteger)
#define MKUIntegerProperty(name) MKProperty(name, assign, NSUInteger)
#define MKBoolProperty(name) MKProperty(name, assign, BOOL)
#define MKBoolGetterProperty(name, customGetter) @property (nonatomic, assign, getter=customGetter) BOOL name;
#define MKDataProperty(name) MKProperty(name, strong, NSData *)
#define MKDictionaryProperty(name) MKProperty(name, strong, NSDictionary *)


// ---------------------------------------------------------
// Entity, Endpoint, Device, Client
// ---------------------------------------------------------

@protocol MKEntityEndpointDeviceClientProperties <JSExport>

MKStringProperty(name);
MKUIntegerProperty(maxSysExSpeed);
MKUIntegerProperty(advanceScheduleTimeMuSec);

@end
// ---------------------------------------------------------


// ---------------------------------------------------------
// Device, Endpoint, Entity
// ---------------------------------------------------------
@protocol MKDeviceEntityEndpointProperties <JSExport>

@property (nonatomic, assign) MIDIUniqueID uniqueID;

MKStringProperty(deviceID);
MKStringProperty(driverOwner);
MKStringProperty(displayName);
MKIntegerProperty(connectionUniqueID);
MKIntegerProperty(driverVersion);
MKBoolGetterProperty(offline, isOffline);
MKBoolGetterProperty(online, isOnline);
MKBoolGetterProperty(private, isPrivate);
MKDataProperty(patchNameFile);
MKDataProperty(userPatchNameFile);

@end
// ---------------------------------------------------------


// ---------------------------------------------------------
// Entity, endpoint
// ---------------------------------------------------------
@protocol MKEntityEndpointProperties <JSExport>

MKBoolGetterProperty(embeddedEntity,    isEmbeddedEntity);
MKBoolGetterProperty(broadcast,         isBroadcast);

@end
// ---------------------------------------------------------


// ---------------------------------------------------------
// Device, Endpoint
// ---------------------------------------------------------
@protocol MKDeviceEndpointProperties <JSExport>

MKStringProperty(manufacturer);
MKStringProperty(model);

@end
// ---------------------------------------------------------


// ---------------------------------------------------------
// Device, Entity
// ---------------------------------------------------------
@protocol MKDeviceEntityProperties <JSExport>

MKBoolProperty(supportsGeneralMIDI);
MKBoolProperty(supportsMMC);
MKBoolProperty(canRoute);
MKBoolProperty(receivesClock);
MKBoolProperty(receivesNotes);
MKBoolProperty(receivesProgramChanges);
MKBoolProperty(receivesBankSelectMSB);
MKBoolProperty(receivesBankSelectLSB);
MKBoolProperty(transmitsClock);
MKBoolProperty(transmitsMTC);
MKBoolProperty(transmitsNotes);
MKBoolProperty(transmitsProgramChanges);
MKBoolProperty(transmitsBankSelectMSB);
MKBoolProperty(transmitsBankSelectLSB);
MKBoolProperty(panDisruptsStereo);
MKBoolProperty(supportsShowControl);
MKBoolGetterProperty(sampler, isSampler);
MKBoolGetterProperty(drumMachine, isDrumMachine);
MKBoolGetterProperty(mixer, isMixer);
MKBoolGetterProperty(effectUnit, isEffectUnit);
MKIntegerProperty(maxReceiveChannels);
MKIntegerProperty(maxTransmitChannels);
// ---------------------------------------------------------

@end


// ---------------------------------------------------------
// Entity
// ---------------------------------------------------------
@protocol MKEntityProperties <MKEntityEndpointDeviceClientProperties, MKDeviceEntityProperties, MKEntityEndpointProperties, MKDeviceEntityEndpointProperties, JSExport>

MKUIntegerProperty(receiveChannelBits);
MKUIntegerProperty(transmitChannelBits);

- (BOOL)transmitsOnChannel:(NSUInteger)channel;
- (BOOL)receivesOnChannel:(NSUInteger)channel;
- (instancetype)setTransmits:(BOOL)transmits onChannel:(NSUInteger)channel;
- (instancetype)setReceives:(BOOL)receives onChannel:(NSUInteger)channel;

@end
// ---------------------------------------------------------


// ---------------------------------------------------------
// Endpoint
// ---------------------------------------------------------
@protocol MKEndpointProperties <MKEntityEndpointDeviceClientProperties, MKDeviceEndpointProperties, MKEntityEndpointProperties, MKDeviceEntityEndpointProperties, JSExport>

@end
// ---------------------------------------------------------


// ---------------------------------------------------------
// Device
// ---------------------------------------------------------
@protocol MKDeviceProperties <MKEntityEndpointDeviceClientProperties, MKDeviceEntityProperties, MKDeviceEndpointProperties, MKDeviceEntityEndpointProperties, JSExport>

MKStringProperty(iconImagePath);
MKStringProperty(driverDeviceEditorApp);
MKIntegerProperty(singleRealtimeEntity);

@end
// ---------------------------------------------------------


// ---------------------------------------------------------
// Client
// ---------------------------------------------------------
@protocol MKClientProperties <MKEntityEndpointDeviceClientProperties>

@end