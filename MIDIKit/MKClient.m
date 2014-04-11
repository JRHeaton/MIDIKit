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

@interface MKClient ()

@property (nonatomic, strong) NSMutableSet *notificationDelegates;

@end

@implementation MKClient

static void _MKClientMIDINotifyProc(const MIDINotification *message, void *refCon) {
    MKClient *self = (__bridge MKClient *)(refCon);

    switch((SInt32)message->messageID) {
        case kMIDIMsgSetupChanged: break;
        case kMIDIMsgObjectAdded:
        case kMIDIMsgObjectRemoved: {
            MIDIObjectAddRemoveNotification *notif = (MIDIObjectAddRemoveNotification *)message;
            
        } break;
        case kMIDIMsgPropertyChanged: break;
        case kMIDIMsgThruConnectionsChanged: break;
        case kMIDIMsgSerialPortOwnerChanged: break;
        case kMIDIMsgIOError: break;
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
        self.notificationDelegates = [NSMutableSet setWithCapacity:0];

        MIDIClientCreate(cfName, _MKClientMIDINotifyProc, (__bridge void *)(self), &val);
        self.MIDIRef = val;
    }

    return self;
}

- (instancetype)init {
    return [self initWithName:[NSString stringWithFormat:@"%s-client", getprogname()]];
}

- (void)dealloc {
    MIDIClientDispose(self.MIDIRef);
}

- (void)enumerateDevicesUsingBlock:(void (^)(MKDevice *device))enumerationBlock
                  constructorBlock:(MKDevice *(^)(MKDevice *rootDev))constructorBlock
              restrictWithCriteria:(BOOL (^)(MKDevice *rootDev))criteriaBlock {
    
    for(NSUInteger i=0;i<self.numberOfDevices;++i) {
        MKDevice *rootDev = [[MKDevice alloc] initWithMIDIRef:MIDIGetDevice(i)];
        if((criteriaBlock && criteriaBlock(rootDev)) || !criteriaBlock) {
            enumerationBlock(!constructorBlock ? rootDev : (constructorBlock(rootDev) ?: rootDev));
        }
    }
}

- (MKDevice *)deviceAtIndex:(NSUInteger)index {
    return [[MKDevice alloc] initWithMIDIRef:MIDIGetDevice(index)];
}

- (NSUInteger)numberOfDestinations {
    return MIDIGetNumberOfDestinations();
}

- (NSUInteger)numberOfDevices {
    return  MIDIGetNumberOfDevices();
}

- (NSUInteger)numberOfSources {
    return MIDIGetNumberOfSources();
}

- (void)dispose {
    MIDIClientDispose(self.MIDIRef);
    self.MIDIRef = 0;
}

- (MKInputPort *)firstInputPort {
    return !self.inputPorts.count ? self.createInputPort : self.inputPorts[0];
}

- (MKInputPort *)firstOutputPort {
    return !self.outputPorts.count ? self.createOutputPort : self.outputPorts[0];
}

- (MKInputPort *)createInputPort {
    return [[MKInputPort alloc] initWithName:[NSString stringWithFormat:@"%@-Input-%lu", self.name, (unsigned long)self.inputPorts.count] client:self];
}

- (MKOutputPort *)createOutputPort {
    return [[MKOutputPort alloc] initWithName:[NSString stringWithFormat:@"%@-Output-%lu", self.name, (unsigned long)self.outputPorts.count] client:self];
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

@end
