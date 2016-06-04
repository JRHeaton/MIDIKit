import CoreMIDI

extension MIDIPacketList: SequenceType {
	public func generate() -> AnyGenerator<MIDIPacket> {
		var iterator: MIDIPacket?
		var nextIndex: UInt32 = 0
		
		return AnyGenerator {
			nextIndex += 1
			if nextIndex > self.numPackets { return nil }
			
			if var last = iterator {
				iterator = withUnsafePointer(&last) { MIDIPacketNext($0).memory }
			} else {
				iterator = self.packet
			}
			return iterator
		}
	}
}
