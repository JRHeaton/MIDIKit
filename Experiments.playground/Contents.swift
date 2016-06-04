import MIDIKit
import Launchpad

do {
	let connection = try Connection()
	
	if let dest = Destination.allLazy
		.filter({ $0[.Name] == "Launchpad S" })
		.first {
		connection.destinations.append(dest)
		
		let send = { (cmd: Launchpad.Command) in try connection.send(cmd, onChannel: 0) }
		
		let cmds = Command.fillGrid { row, column in
			func rando(max: Command.Brightness = .Full) -> Command.Brightness {
				return arc4random() % 2 == 0 ? .Off : max
			}
			return (rando(), rando(.Low))
		}
		try cmds.forEach { try connection.send($0, onChannel: 0) }
		try connection.outputPort.send([0xb0, 0x69, 127], toDestination: dest)
//		try send(.Reset)
	}
	
//	CFRunLoopRun()
	
} catch let error {
	print(error)
}
