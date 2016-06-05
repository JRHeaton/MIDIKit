import MIDIKit
import Launchpad

import CoreMIDI
import Foundation
let x = mach_absolute_time()
sleep(1)
x.secondsAgo


do {
	let client = try Client()
	let outputPort = try client.createOutputPort()
	let inputPort = try client.createInputPort { packet, source in
		print("\(source) sent \(packet) ")
	}
	
	if let dest = Destination.allLazy
		.filter({ $0[.Name] == "Launchpad S" })
		.first {
		
		print("sending light commands...")
		try outputPort.send(
			Command.fillGrid { row, column in
				func rando(max: Brightness = .Full) -> Brightness {
					return arc4random() % 2 == 0 ? .Off : max
				}
				return (rando(), rando())
			},
			onChannel: 0,
			toDestination: dest)
		
		//		try send(.Reset)
	} else {
		print("Launchpad destination not found")
	}
	
	if let src = Source.allLazy
		.filter({ $0[.Name] == "Launchpad S" })
		.first {
		try inputPort.connectSource(src)
		print("source connected. listening...")
		
		CFRunLoopRun()
	} else {
		print("Launchpad source not found")
	}
	
} catch let error {
	print(error)
}
