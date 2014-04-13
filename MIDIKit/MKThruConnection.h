//
//  MKThruConnection.h
//  MIDIKit
//
//  Created by John Heaton on 4/13/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <CoreMIDI/CoreMIDI.h>

typedef UInt8 (^MKThruConnectionChannelMap)(UInt8 channel);

@class MKEndpoint;
@protocol MKThruConnectionJS <JSExport>

+ (instancetype)defaultConnection;
+ (instancetype)defaultConnectionWithOwner:(NSString *)owner;
+ (NSArray *)connectionsForOwner:(NSString *)ownerID;

- (instancetype)dispose;

@property (nonatomic, assign) BOOL filterOutSysEx;
@property (nonatomic, assign) BOOL filterOutMTC;
@property (nonatomic, assign) BOOL filterOutBeatClock;
@property (nonatomic, assign) BOOL filterOutTuneRequest;
@property (nonatomic, assign) BOOL filterOutAllControls;

@property (nonatomic, assign) UInt16 numControlTransforms;
@property (nonatomic, assign) UInt16 numMaps;

@property (nonatomic, assign) UInt8 lowVelocity, highVelocity;
@property (nonatomic, assign) UInt8 lowNote, highNote;

@property (nonatomic, readonly) NSMutableArray *sources;
@property (nonatomic, readonly) NSMutableArray *destinations;
- (instancetype)addSource:(MKEndpoint *)source;
- (instancetype)addDestination:(MKEndpoint *)destination;
- (BOOL)containsSource:(MKEndpoint *)source;
- (BOOL)containsDestination:(MKEndpoint *)destination;

@property (nonatomic, assign) MIDIThruConnectionParams *connectionParams;

- (instancetype)mapChannels:(MKThruConnectionChannelMap *)mapBlock;
- (instancetype)unmapChannels;

@end

@interface MKThruConnection : NSObject <MKThruConnectionJS>

+ (instancetype)connectionWithOwner:(NSString *)ownerID connectionParams:(MIDIThruConnectionParams *)params;

@end
