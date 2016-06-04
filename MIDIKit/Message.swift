import CoreMIDI

public protocol ChannelMessageConvertible {
	var channelMessage: ChannelMessage { get }
}

extension ChannelMessage: ChannelMessageConvertible {
	public var channelMessage: ChannelMessage {
		return self
	}
}

public enum ChannelMessage {
	case NoteOff(key: UInt8, velocity: UInt8)
	case NoteOn(key: UInt8, velocity: UInt8)
	case KeyAftertouch(key: UInt8, pressure: UInt8)
	case ControlChange(controller: UInt8, value: UInt8)
	case ProgramChange(program: UInt8)
	case ChannelAftertouch(pressure: UInt8)
	case PitchBend(value: UInt16)
	
	func on(channel channel: Int) -> [UInt8] {
		func status(statusByte: UInt8) -> UInt8 {
			return statusByte | (UInt8(channel) & 0xF)
		}
		switch self {
		case let .NoteOff(key, velocity):
			return [status(0x80), key, velocity]
		case let .NoteOn(key, velocity):
			return [status(0x90), key, velocity]
		case let .KeyAftertouch(key, pressure):
			return [status(0xA0), key, pressure]
		case let .ControlChange(controller, value):
			return [status(0xB0), controller, value]
		case let .ProgramChange(program):
			return [status(0xC0), program]
		case let .ChannelAftertouch(pressure):
			return [status(0xD0), pressure]
		case let .PitchBend(value):
			return [status(0xE0), UInt8(value & 0xFF), UInt8((value & 0xFF00) >> 8)]
		}
	}
}
