import CoreMIDI

public struct Packet {
	public var timeStamp: MIDITimeStamp
	public var data: [UInt8]
	
	public init(timeStamp: MIDITimeStamp = .Now, data: [UInt8]) {
		precondition(data.count <= Int(UInt16.max)) // max packet size
		self.timeStamp = timeStamp
		self.data = data
	}
	
	internal func withPacketPointer(@noescape closure: (UnsafePointer<MIDIPacket>) throws -> ()) rethrows {
		let fullSize = MIDIPacket.HeaderSize + data.count
		let bytePointer = UnsafeMutablePointer<UInt8>.alloc(fullSize)
		defer { bytePointer.dealloc(fullSize) }
		let packetPointer = UnsafeMutablePointer<MIDIPacket>(bytePointer)
		packetPointer.memory.timeStamp = timeStamp
		packetPointer.memory.length = UInt16(data.count)
		let buffer = UnsafeMutableBufferPointer<UInt8>(
			start: bytePointer.advancedBy(MIDIPacket.HeaderSize),
			count: data.count)
		data.enumerate().forEach { buffer[$0.index] = $0.element }
		try closure(packetPointer)
	}
}
