//
//  MKClient.m
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKClient.h"

@interface MKClient ()

@property (nonatomic, strong) NSMutableSet *notificationDelegates;

@end

static void MKClientInputCB(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
//    MKClient *self = (__bridge MKClient *)(readProcRefCon);

    NSLog(@"input");
}

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
        
        self.notificationDelegates = [NSMutableSet setWithCapacity:0];

        MIDIClientCreate(cfName, _MKClientMIDINotifyProc, (__bridge void *)(self), &val);
        self.MIDIRef = val;

        MIDIOutputPortCreate(self.MIDIRef, cfName, &val);
        self->_outputPort = [[MKObject alloc] initWithMIDIRef:val];
        MIDIInputPortCreate(self.MIDIRef, cfName, MKClientInputCB, (__bridge void *)(self), &val);
        self->_inputPort = [[MKInputPort alloc] initWithMIDIRef:val];
    }

    return self;
}

- (instancetype)init {
    return [self initWithName:[NSString stringWithFormat:@"%s-client", getprogname()]];
}

- (void)dealloc {
    MIDIPortDispose(self.inputPort.MIDIRef);
    MIDIPortDispose(self.outputPort.MIDIRef);
    MIDIClientDispose(self.MIDIRef);
}

- (void)enumerateDevicesUsingBlock:(void (^)(MKDevice *device))enumerationBlock
                  constructorBlock:(MKDevice *(^)(MIDIDeviceRef dev))constructorBlock {
    
    for(NSUInteger i=0;i<self.numberOfDevices;++i) {
        enumerationBlock(!constructorBlock ? [self deviceAtIndex:i] : (constructorBlock(MIDIGetDevice(i)) ?: [self deviceAtIndex:i]));
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

- (void)sendData:(NSData *)data toEndpoint:(MKEndpoint *)endpoint {
    MIDIPacketList list;
    if(data.length <= 256) {
        list.numPackets = 1;
        list.packet[0].timeStamp = 0;
        list.packet[0].length = data.length;
        memcpy(list.packet[0].data, data.bytes, data.length);
    } else {
//        UInt8 *dat = (UInt8 *)data.bytes;
//        MIDIPacket *p = MIDIPacketListInit(&list);
//
//        NSUInteger remainder = data.length % 256;
//
//        for(NSUInteger i=0;i<data.length / 256;++i) {
//            p = MIDIPacketListAdd(&list, i*256, p, 0, MIN(, <#const Byte *data#>)
//        }
    }

    MIDISend(self.outputPort.MIDIRef, endpoint.MIDIRef, (const MIDIPacketList *)&list);
}

- (void)sendDataArray:(NSArray *)array toEndpoint:(MKEndpoint *)endpoint {
    NSMutableData *data = [NSMutableData dataWithLength:array.count];
    for(NSNumber *byte in array) {
        UInt8 val = byte.unsignedCharValue;
        [data appendBytes:&val length:1];
    }
    [self sendData:data toEndpoint:endpoint];
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
