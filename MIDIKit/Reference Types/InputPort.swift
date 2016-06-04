//
//  InputPort.swift
//  hax
//
//  Created by John Heaton on 5/14/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

import CoreMIDI

public final class InputPort: Object {
	public let ref: MIDIPortRef
	
	public init(client: Client, name: String = "") throws {
		var _ref: MIDIPortRef = 0
		if let error = Error(MIDIInputPortCreateWithBlock(client.ref, name, &_ref) { pktListPointer, _ in
//			let packetList = pktListPointer.memory
			
			print("input")
		}) { throw error }
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
