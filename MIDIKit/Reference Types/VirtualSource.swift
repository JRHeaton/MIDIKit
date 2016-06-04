import CoreMIDI

public final class VirtualSource: Object {
	public let ref: MIDIEndpointRef
	
	public init(client: Client, name: String = "") throws {
		var result: MIDIEndpointRef = 0
		if let error = Error(MIDISourceCreate(client.ref, name, &result)) {
			throw error
		}
		ref = result
		client.virtualSources.append(self)
	}
	
	deinit {
		MIDIEndpointDispose(ref)
	}
}
