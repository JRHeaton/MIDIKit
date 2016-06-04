import CoreMIDI

/// A type that is or provides a CoreMIDI object
public protocol Object: Equatable {
	var ref: MIDIObjectRef { get }
}

extension MIDIObjectRef: Object {
	public var ref: MIDIObjectRef {
		return self
	}
}

extension Object {
	public var isValid: Bool {
		return ref != 0
	}
}

public func == <A: Object, B: Object>(lhs: A, rhs: B) -> Bool {
	return lhs.ref == rhs.ref
}

extension Object {
	private func integerProperty(property: MIDIPropertyNameConvertible) throws -> Int {
		var result: Int32 = 0
		try Error.throwWith(MIDIObjectGetIntegerProperty(ref, property.midiPropertyName, &result))
		return Int(result)
	}
	
	public func get(property: StringProperty) throws -> String {
		var result: Unmanaged<CFString>?
		try Error.throwWith(MIDIObjectGetStringProperty(ref, property.midiPropertyName, &result))
		let value = result?.takeUnretainedValue() as String? ?? ""
		result?.release()
		return value
	}
	
	public func get(property: IntegerProperty) throws -> Int {
		return try integerProperty(property)
	}
	
	public func get(property: BooleanProperty) throws -> Bool {
		return try Bool(integerProperty(property))
	}
	
	public subscript(property: StringProperty) -> String? {
		return try? get(property)
	}
	
	public subscript(property: IntegerProperty) -> Int? {
		return try? get(property)
	}
	
	public subscript(property: BooleanProperty) -> Bool? {
		return try? get(property)
	}
}
