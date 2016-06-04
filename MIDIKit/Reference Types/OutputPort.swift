import CoreMIDI

public final class OutputPort: Object {
	public let ref: MIDIPortRef
	
	public init(client: Client, name: String = "") throws {
		var result: MIDIPortRef = 0
		try Error.throwWith(MIDIOutputPortCreate(client.ref, name, &result))
		ref = result
		client.outputPorts.append(self)
	}
	
	public func send(
		message: ChannelMessageConvertible,
		onChannel channel: Int,
		toDestination destination: Destination) throws {
		try send(message.channelMessage.dataOnChannel(channel & 0xF), toDestination: destination)
	}
	
	public func send<S: SequenceType where S.Generator.Element: ChannelMessageConvertible>(
		messages: S,
		onChannel channel: Int,
		          toDestination destination: Destination) throws {
		try messages.forEach { try send($0, onChannel: channel, toDestination: destination) }
	}
	
	public func send(packet: Packet, toDestination destination: Destination) throws {
		try packet.withPacketPointer { pktPtr in
			var packetList = MIDIPacketList(numPackets: 1, packet: pktPtr.memory)
			try send(&packetList, toDestination: destination)
		}
	}
	
	public func send<S: SequenceType where S.Generator.Element == Packet>(
		packets: S,
		toDestination destination: Destination) throws {
		try packets.forEach { try send($0, toDestination: destination) }
	}
	
	public func send(bytes: [UInt8],
	                 withTimeStamp timeStamp: MIDITimeStamp = 0,
	                 toDestination destination: Destination) throws {
		try send(Packet(timeStamp: timeStamp, data: bytes), toDestination: destination)
	}
	
	public func send(packetList: UnsafePointer<MIDIPacketList>,
	                 toDestination destination: Destination) throws {
		try Error.throwWith(MIDISend(ref, destination.ref, packetList))
	}
	
	deinit {
		MIDIPortDispose(ref)
	}
}
