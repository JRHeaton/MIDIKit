//
//  Object.swift
//  hax
//
//  Created by John Heaton on 5/14/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

import CoreMIDI

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
		if let error = Error(MIDIObjectGetIntegerProperty(ref, property.midiPropertyName, &result)) {
			throw error
		}
		return Int(result)
	}
	
	public func get(property: StringProperty) throws -> String {
		var result: Unmanaged<CFString>?
		if let error = Error(MIDIObjectGetStringProperty(ref, property.midiPropertyName, &result)) {
			throw error
		}
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
