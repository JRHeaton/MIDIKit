import CoreMIDI

public struct Packet {
	public var timeStamp: MIDITimeStamp
	public var data: [UInt8]
	
	public init(timeStamp: MIDITimeStamp = .Now, data: [UInt8]) {
		precondition(data.count <= Int(UInt16.max)) // max packet size
		self.timeStamp = timeStamp
		self.data = data
	}
}
