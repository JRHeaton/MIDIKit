//
//  MKServer.h
//  MIDIKit
//
//  Created by John Heaton on 4/15/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

// Global MIDI server functions. you needn't ever init this class

@protocol MKServerJS <JSExport>

/**
 *  Restarts the MIDI server
 *
 *  @return YES if successful.
 */
+ (BOOL)restart;

@end

@interface MKServer : NSObject <MKServerJS>

@end
