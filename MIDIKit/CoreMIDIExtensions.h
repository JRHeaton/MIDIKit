//
//  CoreMIDIExtensions.h
//  MIDIKit
//
//  Created by John Heaton on 6/5/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

#ifndef CoreMIDIExtensions_h
#define CoreMIDIExtensions_h

#include <CoreMIDI/CoreMIDI.h>

void MIDIPacketListEnumerate(const MIDIPacketList *packetList,
							 void (^closure)(UInt8 *data, UInt16 length, MIDITimeStamp timeStamp));
OSStatus MIDISendData(MIDIPortRef outputPort,
					  MIDIEndpointRef destination,
					  const UInt8 *data,
					  UInt16 length,
					  MIDITimeStamp timeStamp);

#endif /* CoreMIDIExtensions_h */
