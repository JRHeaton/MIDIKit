//
//  OutputPort.swift
//  hax
//
//  Created by John Heaton on 5/14/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

import CoreMIDI

public final class OutputPort: Object {
	public let ref: MIDIPortRef
	
	public init(client: Client, name: String = "") throws {
		var result: MIDIPortRef = 0
		if let error = Error(MIDIOutputPortCreate(client.ref, name, &result)) {
			throw error
		}
		ref = result
		client.outputPorts.append(self)
	}
	
	public func send(message: ChannelMessageConvertible, onChannel channel: Int, toDestination destination: Destination) {
		let bytes = message.channelMessage.dataOnChannel(channel & 0xF)
		var packet = MIDIPacket()
		packet.length = UInt16(bytes.count)
		packet.timeStamp = 0
		withUnsafeMutablePointer(&packet.data) { ptr in
			let buffer = UnsafeMutableBufferPointer<UInt8>(start: UnsafeMutablePointer(ptr), count: Int(packet.length))
			bytes[0..<bytes.count]
				.enumerate()
				.forEach { buffer[$0.index] = $0.element }
		}
		var packetList = MIDIPacketList(numPackets: 1, packet: packet)
		MIDISend(ref, destination.ref, &packetList)
	}
	
	public func send(packetList: UnsafePointer<MIDIPacketList>, toDestination destination: Destination) {
		MIDISend(ref, destination.ref, packetList)
	}
	
	deinit {
		MIDIPortDispose(ref)
	}
}