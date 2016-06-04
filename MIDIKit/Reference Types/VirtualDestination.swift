import CoreMIDI

public final class VirtualDestination: Object {
	public let ref: MIDIEndpointRef
	
	public init(ref: MIDIEndpointRef) {
		self.ref = ref
	}
	
	public init(client: Client, name: String = "") throws {
		var result: MIDIEndpointRef = 0
		if let error = Error(MIDIDestinationCreateWithBlock(client.ref, name, &result) { pktListPtr, refConPtr in

		}) { throw error }
		ref = result
		client.virtualDestinations.append(self)
	}
	
	deinit {
		MIDIEndpointDispose(ref)
	}
}
