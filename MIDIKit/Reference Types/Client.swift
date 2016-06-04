import CoreMIDI

public final class Client: Object {
	public let ref: MIDIClientRef
	
	public internal(set) var inputPorts: [InputPort] = []
	public internal(set) var outputPorts: [OutputPort] = []
	
	public internal(set) var virtualSources: [VirtualSource] = []
	public internal(set) var virtualDestinations: [VirtualDestination] = []

	public typealias NotificationClosure = (Notification) -> ()
	
	public init(name: String = "", notificationHandler: NotificationClosure? = nil) throws {
		var _ref: MIDIClientRef = 0
		try Error.throwWith(MIDIClientCreateWithBlock(name, &_ref) { notificationPointer in
			notificationHandler?(Notification(notificationPointer))
		})
		ref = _ref
	}
	
	public func firstInputPort(name: String = "") throws -> InputPort {
		return try inputPorts.first ?? (createInputPort(name))
	}
	
	public func firstOutputPort(name: String = "") throws -> OutputPort {
		return try outputPorts.first ?? createOutputPort(name)
	}
	
	public func createInputPort(name: String = "") throws -> InputPort {
		return try .init(client: self, name: name)
	}
	
	public func createOutputPort(name: String = "") throws -> OutputPort {
		return try .init(client: self, name: name)
	}
	
	public func createVirtualSource(name: String = "") throws -> VirtualSource {
		return try .init(client: self, name: name)
	}
	
	public func createVirtualDestination(name: String = "") throws -> VirtualDestination {
		return try .init(client: self, name: name)
	}
	
	deinit {
		MIDIClientDispose(ref)
	}
}
