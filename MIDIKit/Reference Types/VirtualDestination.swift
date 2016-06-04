import CoreMIDI

public final class VirtualDestination: Object {
	public let ref: MIDIEndpointRef
	
	public init(ref: MIDIEndpointRef) {
		self.ref = ref
	}
	
	public init(client: Client, name: String = "") throws {
		var result: MIDIEndpointRef = 0
		try Error.throwWith(MIDIDestinationCreateWithBlock(client.ref, name, &result) { pktListPtr, refConPtr in

		})
		ref = result
		client.virtualDestinations.append(self)
	}
	
	deinit {
		MIDIEndpointDispose(ref)
	}
}
