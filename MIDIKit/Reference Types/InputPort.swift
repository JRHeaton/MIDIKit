import CoreMIDI

public final class InputPort: Object {
	public let ref: MIDIPortRef
	
	public init(client: Client, name: String = "") throws {
		var _ref: MIDIPortRef = 0
		try Error.throwWith(MIDIInputPortCreateWithBlock(client.ref, name, &_ref) { pktListPointer, _ in
//			let packetList = pktListPointer.memory
			
			print("input")
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
