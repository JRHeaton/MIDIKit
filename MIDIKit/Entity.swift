//
//  Entity.swift
//  hax
//
//  Created by John Heaton on 5/14/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

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
	
	public var sourceCount: Int {
		return MIDIEntityGetNumberOfSources(ref)
	}
	public var sources: AnyRandomAccessCollection<Source> {
		return .init((0..<sourceCount)
			.lazy
			.map { MIDIEntityGetSource(self.ref, $0) }
			.map(Source.init))
	}
	
	public var destinationCount: Int {
		return MIDIEntityGetNumberOfDestinations(ref)
	}
	public var destinations: AnyRandomAccessCollection<Destination> {
		return .init((0..<destinationCount)
			.lazy
			.map { MIDIEntityGetDestination(self.ref, $0) }
			.map(Destination.init))
	}
}