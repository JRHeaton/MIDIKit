//
//  CoreMIDIExtensions.c
//  MIDIKit
//
//  Created by John Heaton on 6/5/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

#include "CoreMIDIExtensions.h"

void MIDIPacketListEnumerate(const MIDIPacketList *packetList,
							 void (^closure)(UInt8 *data, UInt16 length, MIDITimeStamp timeStamp)) {
	const MIDIPacket *packet = &packetList->packet[0];
	for (UInt32 i = 0; i < packetList->numPackets; ++i) {
		closure((UInt8 *)packet->data, packet->length, packet->timeStamp);
		packet = MIDIPacketNext(packet);
	}
}

OSStatus MIDISendData(MIDIPortRef outputPort,
					  MIDIEndpointRef destination,
					  const UInt8 *data,
					  UInt16 length,
					  MIDITimeStamp timeStamp) {
	MIDIPacketList *result = NULL;
	static const size_t MIDIPacketHeaderLength = sizeof(UInt16) + sizeof(MIDITimeStamp);
	const size_t packetSize = MIDIPacketHeaderLength + length;
	result = (MIDIPacketList *)calloc(1, sizeof(UInt32) + packetSize);
	result->numPackets = 1;
	result->packet[0].timeStamp = timeStamp;
	result->packet[0].length = length;
	memcpy(&result->packet[0].data, data, length);
	
	OSStatus status = MIDISend(outputPort, destination, result);
	free(result);
	return status;
}
