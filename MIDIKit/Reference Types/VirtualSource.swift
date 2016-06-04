//
//  VirtualSource.swift
//  MIDIKit
//
//  Created by John Heaton on 6/4/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

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
