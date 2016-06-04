import CoreMIDI

public struct Entity: Object {
	public let ref: MIDIEntityRef
	
	public init(ref: MIDIEntityRef) {
		self.ref = ref
	}
	
	public var device: Device? {
		var result: MIDIDeviceRef = 0
		if Error(MIDIEntityGetDevice(ref, &result)) == nil {
			return Device(ref: result)
		}
		return nil
	}
	
	public var sources: AnyRandomAccessCollection<Source> {
		return .init((0..<MIDIEntityGetNumberOfSources(ref))
			.lazy
			.map { MIDIEntityGetSource(self.ref, $0) }
			.map(Source.init))
	}

	public var destinations: AnyRandomAccessCollection<Destination> {
		return .init((0..<MIDIEntityGetNumberOfDestinations(ref))
			.lazy
			.map { MIDIEntityGetDestination(self.ref, $0) }
			.map(Destination.init))
	}
}
