import CoreMIDI

public final class InputPort: Object {
	public let ref: MIDIPortRef
	
	public typealias InputClosure = (Packet, Source) -> ()
	
	public init(client: Client,
	            name: String = "",
	            inputClosure: InputClosure) throws {
		var result: MIDIPortRef = 0
		MIDIInputPortCreateWithBlock(client.ref, name, &result) { pktListPointer, srcPtr in
			let source = UnsafePointer<Source>(srcPtr).memory
			MIDIPacketListEnumerate(pktListPointer) { data, length, timeStamp in
				let bytes = Array<UInt8>(UnsafeBufferPointer(
					start: UnsafePointer(data),
					count: Int(length)))
				inputClosure(Packet(timeStamp: timeStamp, data: bytes), source)
			}
		}
		ref = result
		client.inputPorts.append(self)
	}
	
	public func connectSource(source: Source) throws {
		var copy = source
		try Error.throwWith(MIDIPortConnectSource(ref, source.ref, &copy))
	}
	
	public func disconnectSource(source: Source) throws {
		try Error.throwWith(MIDIPortDisconnectSource(ref, source.ref))
	}
	
	deinit {
		MIDIPortDispose(ref)
	}
}
