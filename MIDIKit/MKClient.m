//
//  MKClient.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"
#import "MKPrivate.h"

NSString *MKObjectPropertyChangedNotification = @"MKObjectPropertyChangedNotification";
NSString *MKUserInfoPropertyNameKey = @"MKUserInfoPropertyNameKey";
NSString *MKUserInfoObjectInstanceKey = @"MKUserInfoObjectInstanceKey";

static NSMapTable *_MKClientNameMap = nil;

@implementation MKClient

@dynamic maxSysExSpeed, name, advanceScheduleTimeMuSec;

static BOOL _MKClientShouldPostNotifications = NO;

@synthesize inputPorts=_inputPorts;
@synthesize outputPorts=_outputPorts;
@synthesize virtualDestinations=_virtualDestinations;
@synthesize virtualSources=_virtualSources;

static void _MKClientMIDINotifyProc(const MIDINotification *message, void *refCon) {
    MKClient *self = (__bridge MKClient *)(refCon);

    NSString *typeName;
    switch((SInt32)message->messageID) {
        case kMIDIMsgSetupChanged: MKDispatchSelectorToDelegates(@selector(midiClientSetupChanged:), self.delegates, @[self]); break;
        case kMIDIMsgObjectAdded: {
            MIDIObjectAddRemoveNotification *notif = (MIDIObjectAddRemoveNotification *)message;

            id objectInstance = [[_MKClassForType(notif->childType, &typeName) alloc] initWithMIDIRef:notif->child];
            MKDispatchSelectorToDelegates(@selector(midiClient:objectAdded:ofType:), self.delegates, @[ self, objectInstance, @(notif->childType)]);

            if(![typeName isEqualToString:@"object"]) {
                MKDispatchSelectorToDelegates(NSSelectorFromString([NSString stringWithFormat:@"midiClient:%@Added:", typeName]), self.delegates, @[ self, objectInstance ]);
            }
        } break;
        case kMIDIMsgObjectRemoved: {
            MIDIObjectAddRemoveNotification *notif = (MIDIObjectAddRemoveNotification *)message;

            id objectInstance = [[_MKClassForType(notif->childType, &typeName) alloc] initWithMIDIRef:notif->child];
            MKDispatchSelectorToDelegates(@selector(midiClient:objectRemoved:ofType:), self.delegates, @[ self, objectInstance, @(notif->childType) ]);

            if(![typeName isEqualToString:@"object"]) {
                MKDispatchSelectorToDelegates(NSSelectorFromString([NSString stringWithFormat:@"midiClient:%@Removed:", typeName]), self.delegates, @[ self, objectInstance ]);
            }
        } break;
        case kMIDIMsgPropertyChanged: {
            MIDIObjectPropertyChangeNotification *notif = (MIDIObjectPropertyChangeNotification *)message;

            id objectInstance = [[_MKClassForType(notif->objectType, nil) alloc] initWithMIDIRef:notif->object];

            CFRetain(notif->propertyName);
            NSString *propertyName = (__bridge_transfer NSString *)notif->propertyName;
            MKDispatchSelectorToDelegates(@selector(midiClient:object:changedValueOfPropertyForKey:), self.delegates, @[ self, objectInstance, propertyName ]);

            if(_MKClientShouldPostNotifications) {
                [[NSNotificationCenter defaultCenter] postNotificationName:MKObjectPropertyChangedNotification
                                                                    object:self
                                                                  userInfo:@{ MKUserInfoPropertyNameKey : propertyName,
                                                                              MKUserInfoObjectInstanceKey : objectInstance
                                                                              }];
            }
        } break;
        case kMIDIMsgThruConnectionsChanged: break;
        case kMIDIMsgSerialPortOwnerChanged: break;
        case kMIDIMsgIOError: {
            MIDIIOErrorNotification *notif = (MIDIIOErrorNotification *)message;
            MKDispatchSelectorToDelegates(@selector(midiClient:driverIOErrorWithDevice:errorCode:), self.delegates, @[ self, [MKDevice objectWithMIDIRef:notif->driverDevice], @(notif->errorCode)]);
        } break;
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MKClientNameMap = [NSMapTable strongToWeakObjectsMapTable];
    });
}

+ (void)startSendingNotifications {
    _MKClientShouldPostNotifications = YES;

    // ensure this is allocated, so a MIDINotifyProc is registered w/ the server
    (void)[self global];
}

+ (void)stopSendingNotifications {
    _MKClientShouldPostNotifications = NO;
}

+ (instancetype)clientWithNameJS:(JSValue *)name {
    return [[self alloc] initWithName:(name.isUndefined || name.isNull) ? nil : name.toString];
}

+ (instancetype)clientWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name {
    MIDIClientRef c;
    static NSUInteger _unnamedCount = 0;
    CFStringRef cfName = (__bridge CFStringRef)(name ?: [NSString stringWithFormat:@"%@-%d-ClientUnnamed-%lu",
                                                         [NSProcessInfo processInfo].processName,
                                                         [NSProcessInfo processInfo].processIdentifier,
                                                         (unsigned long)_unnamedCount++]);
    MKClient *ret;

    if((ret = [_MKClientNameMap objectForKey:name]) != nil) return self = ret;
    if(!name) name = (__bridge NSString *)cfName;
    if([MIDIKit evalOSStatus:MIDIClientCreate(cfName, _MKClientMIDINotifyProc, (__bridge void *)(self), &c) name:@"Creating a client"] != 0) {
        return nil;
    }

    if(!(self = [super initWithMIDIRef:c])) return nil;

    [_MKClientNameMap setObject:self forKey:name];
    
    _inputPorts = [NSMutableArray arrayWithCapacity:0];
    _outputPorts = [NSMutableArray arrayWithCapacity:0];
    _virtualSources = [NSMutableArray arrayWithCapacity:0];
    _virtualDestinations = [NSMutableArray arrayWithCapacity:0];
    _delegates = [NSMutableArray arrayWithCapacity:0];

    return self;
}

+ (instancetype)global {
    static MKClient *global;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        global = [self clientWithName:[NSString stringWithFormat:@"%@-%d-Client", [NSProcessInfo processInfo].processName, [NSProcessInfo processInfo].processIdentifier]];
    });

    return global;
}

- (instancetype)dispose {
    MIDIClientDispose(self.MIDIRef);
    self.MIDIRef = 0;
    return self;
}

- (MKInputPort *)createInputPortNamed:(NSString *)name {
    return [[MKInputPort alloc] initWithName:name client:self];
}

- (MKOutputPort *)createOutputPortNamed:(NSString *)name {
    return [[MKOutputPort alloc] initWithName:name client:self];
}

- (MKVirtualSource *)createVirtualSourceNamed:(NSString *)name {
    return [[MKVirtualSource alloc] initWithName:name client:self];
}

- (MKVirtualDestination *)createVirtualDestinationNamed:(NSString *)name {
    return [[MKVirtualDestination alloc] initWithName:name client:self];
}

- (instancetype)addDelegate:(id<MKClientDelegate>)delegate {
    [self.delegates addObject:delegate];
    return self;
}

- (instancetype)removeDelegate:(id<MKClientDelegate>)delegate {
    [self.delegates removeObject:delegate];
    return self;
}

- (MKVirtualSource *)createVirtualSource {
    return [self createVirtualSourceNamed:nil];
}

- (MKVirtualDestination *)createVirtualDestination {
    return [self createVirtualDestinationNamed:nil];
}

- (MKInputPort *)createInputPort {
    return [self createInputPortNamed:nil];
}

- (MKOutputPort *)createOutputPort {
    return [self createOutputPortNamed:nil];
}

- (MKInputPort *)firstInputPort {
    return !self.inputPorts.count ? self.createInputPort : self.inputPorts.firstObject;
}

- (MKInputPort *)firstOutputPort {
    return !self.outputPorts.count ? self.createOutputPort : self.outputPorts.firstObject;
}

@end
