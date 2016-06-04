import CoreMIDI

extension MIDIPacket {
	static let HeaderSize = sizeof(MIDITimeStamp) + sizeof(UInt16)
}
