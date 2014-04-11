//
//  MKClient.h
//  MIDIKit
//
//  Created by John Heaton on 3/23/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKDevice.h"

@class MKInputPort, MKOutputPort, MKVirtualSource, MKVirtualDestination;
@protocol MKClientNotificationDelegate;
@interface MKClient : MKObject

+ (instancetype)clientWithName:(NSString *)name;

- (void)enumerateDevicesUsingBlock:(void (^)(MKDevice *device))enumerationBlock
                  constructorBlock:(MKDevice *(^)(MKDevice *rootDev))constructorBlock
              restrictWithCriteria:(BOOL (^)(MKDevice *rootDev))criteriaBlock;

- (MKDevice *)deviceAtIndex:(NSUInteger)index;

- (void)addNotificationDelegate:(id<MKClientNotificationDelegate>)delegate;
- (void)removeNotificationDelegate:(id<MKClientNotificationDelegate>)delegate;

- (void)dispose;

- (MKInputPort *)firstInputPort;
- (MKOutputPort *)firstOutputPort;
- (MKInputPort *)createInputPort;
- (MKOutputPort *)createOutputPort;
- (MKVirtualSource *)createVirtualSourceNamed:(NSString *)name;
- (MKVirtualDestination *)createVirtualDestinationNamed:(NSString *)name;

@property (nonatomic, readonly) NSUInteger numberOfDevices;
@property (nonatomic, readonly) NSUInteger numberOfDestinations;
@property (nonatomic, readonly) NSUInteger numberOfSources;

@property (nonatomic, readonly) NSMutableArray *outputPorts;
@property (nonatomic, readonly) NSMutableArray *inputPorts;
@property (nonatomic, readonly) NSMutableArray *virtualSources;
@property (nonatomic, readonly) NSMutableArray *virtualDestinations;

@end

@protocol MKClientDependentInstaniation <NSObject>

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client;

@property (nonatomic, weak) MKClient *client;

@end