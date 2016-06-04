//
//  MIDIPropertyNameConvertible.swift
//  MIDIKit
//
//  Created by John Heaton on 6/4/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

import Foundation

internal protocol MIDIPropertyNameConvertible {
	var midiPropertyName: CFString { get }
}
