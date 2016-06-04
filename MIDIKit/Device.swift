//
//  Device.swift
//  hax
//
//  Created by John Heaton on 5/14/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

import CoreMIDI

public struct Device: Object, Enumerable {
	public let ref: MIDIDeviceRef
	
	public static func atIndex(index: Int) -> Device {
		return Device(ref: MIDIGetDevice(index))
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
