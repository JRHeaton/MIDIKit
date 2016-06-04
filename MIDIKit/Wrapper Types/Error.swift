import CoreMIDI

public enum Error: ErrorType {
	case InvalidClient
	case InvalidPort
	case WrongEndpointType
	case NoConnection
	case UnknownEndpoint
	case UnknownProperty
	case WrongPropertyType
	case NoCurrentSetup
	case MessageSendFailure
	case ServerStartFailure
	case SetupFormatFailure
	case WrongThread
	case ObjectNotFound
	case IDNotUnique
	case NotPermitted
	case Unknown(OSStatus)
	
	public init?(_ status: OSStatus) {
		switch status {
		case 0:
			return nil
		case kMIDIInvalidClient:
			self = .InvalidClient
		case kMIDIInvalidPort:
			self = .InvalidPort
		case kMIDIWrongEndpointType:
			self = .WrongEndpointType
		case kMIDINoConnection:
			self = .NoConnection
		case kMIDIUnknownEndpoint:
			self = .UnknownEndpoint
		case kMIDIUnknownProperty:
			self = .UnknownProperty
		case kMIDIWrongPropertyType:
			self = .WrongEndpointType
		case kMIDINoCurrentSetup:
			self = .NoCurrentSetup
		case kMIDIMessageSendErr:
			self = .MessageSendFailure
		case kMIDIServerStartErr:
			self = .ServerStartFailure
		case kMIDISetupFormatErr:
			self = .SetupFormatFailure
		case kMIDIWrongThread:
			self = .WrongThread
		case kMIDIObjectNotFound:
			self = .ObjectNotFound
		case kMIDIIDNotUnique:
			self = .IDNotUnique
		case kMIDINotPermitted:
			self = .NotPermitted
		default:
			self = .Unknown(status)
		}
	}
	
	static func throwWith(status: OSStatus) throws {
		if let error = Error(status) {
			throw error
		}
	}
}
