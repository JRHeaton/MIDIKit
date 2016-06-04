//
//  Client.swift
//  hax
//
//  Created by John Heaton on 5/14/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

import CoreMIDI

public final class Client: Object {
	public let ref: MIDIClientRef
	
	public internal(set) var inputPorts: [InputPort] = []
	public internal(set) var outputPorts: [OutputPort] = []

	public typealias NotificationClosure = (Notification) -> ()
	
	public init(name: String = "", notificationHandler: NotificationClosure? = nil) throws {
		var _ref: MIDIClientRef = 0
		if let error = Error(MIDIClientCreateWithBlock(name, &_ref) { notificationPointer in
			notificationHandler?(Notification(notificationPointer))
		}) { throw error }
		ref = _ref
	}
	
	public func firstInputPort(name: String = "") throws -> InputPort {
		return try inputPorts.first ?? (try createInputPort(name))
	}
	
	public func firstOutputPort(name: String = "") throws -> OutputPort {
		return try outputPorts.first ?? (try createOutputPort(name))
	}
	
	public func createInputPort(name: String = "") throws -> InputPort {
		return try InputPort(client: self, name: name)
	}
	
	public func createOutputPort(name: String = "") throws -> OutputPort {
		return try OutputPort(client: self, name: name)
	}
	
	deinit {
		MIDIClientDispose(ref)
	}
}
