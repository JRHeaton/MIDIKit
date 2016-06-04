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
	
	public func send(
		message: ChannelMessageConvertible,
		onChannel channel: Int,
		toDestination destination: Destination) throws {
		let bytes = message.channelMessage.dataOnChannel(channel & 0xF)
		var packet = MIDIPacket()
		packet.length = UInt16(bytes.count)
		packet.timeStamp = 0
		withUnsafeMutablePointer(&packet.data) { ptr in
			let buffer = UnsafeMutableBufferPointer<UInt8>(
				start: UnsafeMutablePointer(ptr),
				count: Int(packet.length))
			bytes[0..<bytes.count]
				.enumerate()
				.forEach { buffer[$0.index] = $0.element }
		}
		var packetList = MIDIPacketList(numPackets: 1, packet: packet)
		try self.send(&packetList, toDestination: destination)
	}
	
	public func send(packetList: UnsafePointer<MIDIPacketList>,
	                 toDestination destination: Destination) throws {
		if let error = Error(MIDISend(ref, destination.ref, packetList)) {
			throw error
		}
	}
	
	deinit {
		MIDIPortDispose(ref)
	}
}
