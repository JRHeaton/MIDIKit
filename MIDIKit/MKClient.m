//
//  MKClient.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MIDIKit.h"

NSString *MKObjectPropertyChangedNotification = @"MKObjectPropertyChangedNotification";
NSString *MKUserInfoPropertyNameKey = @"MKUserInfoPropertyNameKey";
NSString *MKUserInfoObjectInstanceKey = @"MKUserInfoObjectInstanceKey";

static NSMapTable *_MKClientNameMap = nil;

@interface MKClient ()

@property (nonatomic, strong) NSMutableSet *notificationDelegates;

@end

@implementation MKClient

@dynamic maxSysExSpeed, name, advanceScheduleTimeMuSec;

static BOOL _MKClientShouldPostNotifications = NO;

@synthesize inputPorts=_inputPorts;
@synthesize outputPorts=_outputPorts;
@synthesize virtualDestinations=_virtualDestinations;
@synthesize virtualSources=_virtualSources;

static Class _MKClassForType(MIDIObjectType type, NSString **objectTypeName) {
    Class c;
    NSString *n;
    switch(type & ~kMIDIObjectType_ExternalMask) {
        case kMIDIObjectType_Device: c = [MKDevice class]; n = @"device"; break;
        case kMIDIObjectType_Destination: c = [MKDestination class]; n = @"destination"; break;
        case kMIDIObjectType_Source: c = [MKSource class]; n = @"source"; break;
        case kMIDIObjectType_Entity: c = [MKEntity class]; n = @"entity"; break;
        default: c = [MKObject class]; n = @"object"; break;
    }
    if(objectTypeName) {
        *objectTypeName = n.copy;
    }
    
    return c;
}

static void _MKClientMIDINotifyProc(const MIDINotification *message, void *refCon) {
    MKClient *self = (__bridge MKClient *)(refCon);

    NSString *typeName;
    switch((SInt32)message->messageID) {
        case kMIDIMsgSetupChanged: [self dispatchNotificationSelector:@selector(midiClientSetupChanged:) withArguments:@[self]]; break;
        case kMIDIMsgObjectAdded: {
            MIDIObjectAddRemoveNotification *notif = (MIDIObjectAddRemoveNotification *)message;

            id objectInstance = [[_MKClassForType(notif->childType, &typeName) alloc] initWithMIDIRef:notif->child];
            [self dispatchNotificationSelector:@selector(midiClient:objectAdded:ofType:) withArguments:@[ self, objectInstance, @(notif->childType) ]];

            if(![typeName isEqualToString:@"object"]) {
                [self dispatchNotificationSelector:NSSelectorFromString([NSString stringWithFormat:@"midiClient:%@Added:", typeName]) withArguments:@[ self, objectInstance ]];
            }
        } break;
        case kMIDIMsgObjectRemoved: {
            MIDIObjectAddRemoveNotification *notif = (MIDIObjectAddRemoveNotification *)message;

            id objectInstance = [[_MKClassForType(notif->childType, &typeName) alloc] initWithMIDIRef:notif->child];
            [self dispatchNotificationSelector:@selector(midiClient:objectRemoved:ofType:) withArguments:@[ self, objectInstance, @(notif->childType) ]];

            if(![typeName isEqualToString:@"object"]) {
                [self dispatchNotificationSelector:NSSelectorFromString([NSString stringWithFormat:@"midiClient:%@Removed:", typeName]) withArguments:@[ self, objectInstance ]];
            }
        } break;
        case kMIDIMsgPropertyChanged: {
            MIDIObjectPropertyChangeNotification *notif = (MIDIObjectPropertyChangeNotification *)message;

            id objectInstance = [[_MKClassForType(notif->objectType, nil) alloc] initWithMIDIRef:notif->object];

            CFRetain(notif->propertyName);
            NSString *propertyName = (__bridge_transfer NSString *)notif->propertyName;
            [self dispatchNotificationSelector:@selector(midiClient:object:changedValueOfPropertyForKey:) withArguments:@[ self, objectInstance, propertyName ] ];

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
            [self dispatchNotificationSelector:@selector(midiClient:driverIOErrorWithDevice:errorCode:) withArguments:@[ self, [MKDevice objectWithMIDIRef:notif->driverDevice], @(notif->errorCode)]];
        } break;
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MKClientNameMap = [NSMapTable strongToWeakObjectsMapTable];
    });
}

- (void)dispatchNotificationSelector:(SEL)selector withArguments:(NSArray *)arguments {
    if(!self.notificationDelegates.count) return;

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self.notificationDelegates.anyObject methodSignatureForSelector:selector]];
    [invocation setSelector:selector];

    for(NSUInteger i=0;i<arguments.count;++i) {
        __unsafe_unretained id val = arguments[i];
        [invocation setArgument:&val atIndex:i + 2];
    }

    for(NSObject<MKClientNotificationDelegate> *delegate in self.notificationDelegates) {
        if([delegate respondsToSelector:selector]) {
            [invocation invokeWithTarget:delegate];
        }
    }
}

+ (void)startSendingNotifications {
    _MKClientShouldPostNotifications = YES;

    // ensure this is allocated, so a MIDINotifyProc is registered w/ the server
    (void)[self global];
}

+ (void)stopSendingNotifications {
    _MKClientShouldPostNotifications = NO;
}

+ (instancetype)clientWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name {
    MIDIClientRef c;
    CFStringRef cfName = (__bridge CFStringRef)(name);
    MKClient *ret;

    if((ret = [_MKClientNameMap objectForKey:name]) != nil) return self = ret;
    if(!name) return [self init];
    if([MIDIKit evalOSStatus:MIDIClientCreate(cfName, _MKClientMIDINotifyProc, (__bridge void *)(self), &c) name:@"Creating a client"] != 0) {
        return nil;
    }

    if(!(self = [super initWithMIDIRef:c])) return nil;

    [_MKClientNameMap setObject:self forKey:name];
    
    _inputPorts = [NSMutableArray arrayWithCapacity:0];
    _outputPorts = [NSMutableArray arrayWithCapacity:0];
    _virtualSources = [NSMutableArray arrayWithCapacity:0];
    _virtualDestinations = [NSMutableArray arrayWithCapacity:0];
    _notificationDelegates = [NSMutableSet setWithCapacity:0];

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
    return [[MKInputPort alloc] initWithName:name ?: [NSString stringWithFormat:@"%@-Input-%lu", self.name, (unsigned long)self.inputPorts.count] client:self];
}

- (MKOutputPort *)createOutputPortNamed:(NSString *)name {
    return [[MKOutputPort alloc] initWithName:name ?: [NSString stringWithFormat:@"%@-Output-%lu", self.name, (unsigned long)self.outputPorts.count] client:self];
}

- (MKVirtualSource *)createVirtualSourceNamed:(NSString *)name {
    return [[MKVirtualSource alloc] initWithName:name ?: [NSString stringWithFormat:@"%@-VSource-%lu", self.name, (unsigned long)self.virtualSources.count] client:self];
}

- (MKVirtualDestination *)createVirtualDestinationNamed:(NSString *)name {
    return [[MKVirtualDestination alloc] initWithName:name ?: [NSString stringWithFormat:@"%@-VDest-%lu", self.name, (unsigned long)self.virtualDestinations.count] client:self];
}

- (instancetype)addNotificationDelegate:(id<MKClientNotificationDelegate>)delegate {
    [self.notificationDelegates addObject:delegate];
    return self;
}

- (instancetype)removeNotificationDelegate:(id<MKClientNotificationDelegate>)delegate {
    [self.notificationDelegates removeObject:delegate];
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
