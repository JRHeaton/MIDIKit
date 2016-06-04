import CoreMIDI

public struct Device: Object, Enumerable {
	public let ref: MIDIDeviceRef
	
	public init(index: Int) {
		ref = MIDIGetDevice(index)
	}
	
	public static var count: Int {
		return MIDIGetNumberOfDevices()
	}
	
	public init(ref: MIDIDeviceRef) {
		self.ref = ref
	}
	
	public var entities: AnyRandomAccessCollection<Entity> {
		return .init((0..<MIDIDeviceGetNumberOfEntities(ref))
			.lazy
			.map { MIDIDeviceGetEntity(self.ref, $0) }
			.map(Entity.init))
	}
}
