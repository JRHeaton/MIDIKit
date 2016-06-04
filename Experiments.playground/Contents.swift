import MIDIKit

enum LaunchpadCommand: ChannelMessageConvertible {
	enum Brightness: UInt8 {
		case Off		= 0
		case Low		= 1
		case Medium		= 2
		case Full		= 3
	}
	enum DoubleBufferWriteMethod {
		case ClearOtherBuffer
		case WriteToBoth
	}
	enum BufferType {
		case Display
		case Update
	}
	
	case Reset
	case LEDTest
	case Grid(row: Int, column: Int, red: Brightness, green: Brightness, bufferMethod: DoubleBufferWriteMethod)
	case AutoFlashBuffers(enable: Bool)
	case DoubleBufferControl(firstBuffer: BufferType, copyDisplayStatesToUpdateBuffer: Bool)
	
	static func fillGrid(closure: (row: Int, column: Int) -> (red: Brightness, green: Brightness)) -> [LaunchpadCommand] {
		var cmds = [LaunchpadCommand]()
		for row in 0..<8 {
			for column in 0..<8 {
				let (red, green) = closure(row: row, column: column)
				cmds.append(.Grid(row: row, column: column, red: red, green: green, bufferMethod: .ClearOtherBuffer))
			}
		}
		return cmds
	}
	
	var channelMessage: ChannelMessage {
		switch self {
		case .Reset:
			return .ControlChange(controller: 0, value: 0)
		case .LEDTest:
			return .ControlChange(controller: 0, value: 0x7F)
		case let .Grid(row, column, red, green, bufferMethod):
			var velocity: UInt8 = 0
			switch bufferMethod {
			case .ClearOtherBuffer:
				velocity |= 1 << 3
			case .WriteToBoth:
				velocity |= 1 << 2
			}
			velocity |= red.rawValue
			velocity |= green.rawValue << 4
			return .NoteOn(key: (0x10 * UInt8(row)) + UInt8(column), velocity: velocity)
			
		case let .DoubleBufferControl(firstBuffer, copyDisplayStatesToUpdateBuffer):
			var value: UInt8 = 1 << 5
			if case .Update = firstBuffer {
				value |= 1 << 2
			} else {
				value |= 1
			}
			if copyDisplayStatesToUpdateBuffer {
				value |= 1 << 4
			}
			return .ControlChange(controller: 0, value: value)
			
		case .AutoFlashBuffers(let enable):
			return .ControlChange(controller: 0, value: (enable ? (1 << 3) : 0) | (1 << 5))
		}
	}
}



do {
	let connection = try Connection()
	
	if let dest = Destination.allLazy
		.filter({ $0[.Name] == "Launchpad S" })
		.first {
		connection.destinations.append(dest)
	}
	
	let send = { (cmd: LaunchpadCommand) in try connection.send(cmd, onChannel: 0) }
	
	let cmds = LaunchpadCommand.fillGrid { row, column in
		return (.Low, arc4random() % 2 == 0 ? .Off : .Medium)
	}
//	try cmds.forEach { try connection.send($0, onChannel: 0) }
	try send(.Reset)
	
//	CFRunLoopRun()
	
} catch let error {
	print(error)
}
