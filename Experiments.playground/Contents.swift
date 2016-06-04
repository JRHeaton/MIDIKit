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
			return (.Low, arc4random() % 2 == 0 ? .Off : .Medium)
		}
		//	try cmds.forEach { try connection.send($0, onChannel: 0) }
		try send(.Reset)
	}
	
//	CFRunLoopRun()
	
} catch let error {
	print(error)
}
