//
//  MIDIKitTests.swift
//  MIDIKitTests
//
//  Created by John Heaton on 5/14/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

import XCTest
import MIDIKit

class MIDIKitTests: XCTestCase {
	
	func testObjectEquatability() {
		let obj1 = Source(ref: 1)
		let obj2 = Source(ref: 1)
		let obj3 = Source(ref: 2)
		
		XCTAssertEqual(obj1, obj2)
		XCTAssertNotEqual(obj1, obj3)
	}
	
	func testNameCollisions() {
		do {
			let client1 = try Client()
			let client2 = try Client(name: "")
			
			XCTAssertNotEqual(client1, client2)
		} catch {
			XCTFail()
		}
	}
	
	func testInvalidObject() {
		let invalid = Device(ref: 0)
		XCTAssertFalse(invalid.isValid)
	}
}
