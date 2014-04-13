//
//  MKClient.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKClient.h"
#import "MKInputPort.h"
#import "MKOutputPort.h"
#import "MKVirtualSource.h"
#import "MKVirtualDestination.h"
#import "MKDevice.h"

@interface MKClient ()

@property (nonatomic, strong) NSMutableSet *notificationDelegates;

@end

@implementation MKClient

@synthesize inputPorts=_inputPorts;
@synthesize outputPorts=_outputPorts;
@synthesize virtualDestinations=_virtualDestinations;
@synthesize virtualSources=_virtualSources;

static Class _MKClassForType(MIDIObjectType type, NSString **objectTypeName) {
    Class c;
    NSString *n;
    switch(type & ~kMIDIObjectType_ExternalMask) {
        case kMIDIObjectType_Device: c = [MKDevice class]; n = @"device"; break;
        case kMIDIObjectType_Destination: c = [MKEndpoint class]; n = @"destination"; break;
        case kMIDIObjectType_Source: c = [MKEndpoint class]; n = @"source"; break;
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
            NSString *propertyName = ((__bridge NSString *)notif->propertyName).copy;
            [self dispatchNotificationSelector:@selector(midiClient:object:changedValueOfPropertyForKey:) withArguments:@[ self, objectInstance, propertyName ] ];
        } break;
        case kMIDIMsgThruConnectionsChanged: break;
        case kMIDIMsgSerialPortOwnerChanged: break;
        case kMIDIMsgIOError: {
            MIDIIOErrorNotification *notif = (MIDIIOErrorNotification *)message;
            [self dispatchNotificationSelector:@selector(midiClient:driverIOErrorWithDevice:errorCode:) withArguments:@[ self, [MKDevice objectForMIDIRef:notif->driverDevice], @(notif->errorCode)]];
        } break;
    }

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

+ (instancetype)clientWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name {
    if(!name) return [self init];

    if((self = [super init])) {
        CFStringRef cfName = (__bridge CFStringRef)(name);
        MIDIObjectRef val;
        
        _inputPorts = [NSMutableArray arrayWithCapacity:0];
        _outputPorts = [NSMutableArray arrayWithCapacity:0];
        _virtualSources = [NSMutableArray arrayWithCapacity:0];
        _virtualDestinations = [NSMutableArray arrayWithCapacity:0];
        _notificationDelegates = [NSMutableSet setWithCapacity:0];

        MIDIClientCreate(cfName, _MKClientMIDINotifyProc, (__bridge void *)(self), &val);
        self.MIDIRef = val;
    }

    return self;
}

+ (instancetype)client {
    return [[self alloc] init];
}

- (instancetype)init {
    return [self initWithName:[NSString stringWithFormat:@"%@-%d-Client", [NSProcessInfo processInfo].processName, [NSProcessInfo processInfo].processIdentifier]];
}

- (void)dispose {
    MIDIClientDispose(self.MIDIRef);
    self.MIDIRef = 0;
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

- (void)addNotificationDelegate:(id<MKClientNotificationDelegate>)delegate {
    if(![self.notificationDelegates containsObject:delegate])
        [self.notificationDelegates addObject:delegate];
}

- (void)removeNotificationDelegate:(id<MKClientNotificationDelegate>)delegate {
    if([self.notificationDelegates containsObject:delegate])
        [self.notificationDelegates removeObject:delegate];
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
