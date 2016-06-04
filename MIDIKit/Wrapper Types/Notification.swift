import CoreMIDI

public enum Notification {
	case SetupChanged
	case DestinationAdded(Destination)
	case SourceAdded(Source)
	case DeviceAdded(Device)
	case EntityAdded(Entity)
	case DestinationRemoved(Destination)
	case SourceRemoved(Source)
	case DeviceRemoved(Device)
	case EntityRemoved(Entity)
	case ObjectAdded(parent: MIDIObjectRef, child: MIDIObjectRef)
	case ObjectRemoved(parent: MIDIObjectRef, child: MIDIObjectRef)
	case PropertyChanged(object: MIDIObjectRef, property: String)
	case ThruConnectionsChanged
	case SerialPortOwnerChanged
	case DriverIOError(device: Device, errorStatus: OSStatus)
	
	init(_ notificationPointer: UnsafePointer<MIDINotification>) {
		switch notificationPointer.memory.messageID {
		case .MsgSetupChanged:
			self = .SetupChanged
		case .MsgObjectAdded:
			let notif = UnsafePointer<MIDIObjectAddRemoveNotification>(notificationPointer).memory
			switch notif.childType {
			case .Destination:
				self = .DestinationAdded(.init(ref: notif.child))
			case .Device:
				self = .DeviceAdded(.init(ref: notif.child))
			case .Entity:
				self = .EntityAdded(.init(ref: notif.child))
			case .Source:
				self = .SourceAdded(.init(ref: notif.child))
			case .ExternalDestination: fallthrough
			case .ExternalDevice: fallthrough
			case .ExternalEntity: fallthrough
			case .ExternalSource: fallthrough
			case .Other:
				self = .ObjectAdded(parent: notif.parent, child: notif.child)
			}
		case .MsgObjectRemoved:
			let notif = UnsafePointer<MIDIObjectAddRemoveNotification>(notificationPointer).memory
			switch notif.childType {
			case .Destination:
				self = .DestinationRemoved(.init(ref: notif.child))
			case .Device:
				self = .DeviceRemoved(.init(ref: notif.child))
			case .Entity:
				self = .EntityRemoved(.init(ref: notif.child))
			case .Source:
				self = .SourceRemoved(.init(ref: notif.child))
			case .ExternalDestination: fallthrough
			case .ExternalDevice: fallthrough
			case .ExternalEntity: fallthrough
			case .ExternalSource: fallthrough
			case .Other:
				self = .ObjectRemoved(parent: notif.parent, child: notif.child)
			}
		case .MsgPropertyChanged:
			let notif = UnsafePointer<MIDIObjectPropertyChangeNotification>(notificationPointer).memory
			self = .PropertyChanged(object: notif.object,
			                        property: notif.propertyName.takeUnretainedValue() as String)
		case .MsgThruConnectionsChanged:
			self = .ThruConnectionsChanged
		case .MsgSerialPortOwnerChanged:
			self = .SerialPortOwnerChanged
		case .MsgIOError:
			let notif = UnsafePointer<MIDIIOErrorNotification>(notificationPointer).memory
			self = .DriverIOError(device: .init(ref: notif.driverDevice),
			                      errorStatus: notif.errorCode)
		}
	}
}
