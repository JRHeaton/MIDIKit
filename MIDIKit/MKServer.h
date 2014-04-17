//
//  MKServer.h
//  MIDIKit
//
//  Created by John Heaton on 4/15/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol MKServerJS <JSExport>

/**
 *  Restarts the MIDI server
 *
 *  @return YES if successful.
 */
+ (BOOL)restart;

@end

/// Global MIDI server functions. You cannot init this class.
@interface MKServer : NSObject <MKServerJS>

@end
