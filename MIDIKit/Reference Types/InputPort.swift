import CoreMIDI

public final class InputPort: Object {
	public let ref: MIDIPortRef
	
	public typealias InputClosure = (MIDIPacket) -> ()
	
	public init(client: Client,
	            name: String = "",
	            inputClosure: InputClosure) throws {
		var _ref: MIDIPortRef = 0
		try Error.throwWith(MIDIInputPortCreateWithBlock(client.ref, name, &_ref) { pktListPointer, _ in
			for packet in pktListPointer.memory {
				inputClosure(packet)
			}
		})
		ref = _ref
		client.inputPorts.append(self)
	}
	
	public func connectSource(source: Source) {
		MIDIPortConnectSource(ref, source.ref, nil)
	}
	
	public func disconnectSource(source: Source) {
		MIDIPortDisconnectSource(ref, source.ref)
	}
	
	deinit {
		MIDIPortDispose(ref)
	}
}
