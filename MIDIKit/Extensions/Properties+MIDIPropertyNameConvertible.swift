//
//  Properties+CFPropertyName.swift
//  MIDIKit
//
//  Created by John Heaton on 6/4/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

import CoreMIDI

extension StringProperty: MIDIPropertyNameConvertible {
	public var midiPropertyName: CFString {
		switch self {
		case .DisplayName:
			return kMIDIPropertyDisplayName
		case .DriverDeviceEditorApp:
			return kMIDIPropertyDriverDeviceEditorApp
		case .DriverOwner:
			return kMIDIPropertyDriverOwner
		case .DeviceImagePath:
			return kMIDIPropertyImage
		case .Manufacturer:
			return kMIDIPropertyManufacturer
		case .Model:
			return kMIDIPropertyModel
		case .Name:
			return kMIDIPropertyName
		}
	}
}

extension IntegerProperty: MIDIPropertyNameConvertible {
	public var midiPropertyName: CFStringRef {
		switch self {
		case .AdvanceScheduleTimeMuSec:
			return kMIDIPropertyAdvanceScheduleTimeMuSec
		case .ConnectionUniqueID:
			return kMIDIPropertyConnectionUniqueID
		case .DeviceID:
			return kMIDIPropertyDeviceID
		case .DriverVersion:
			return kMIDIPropertyDriverVersion
		case .MaxReceiveChannels:
			return kMIDIPropertyReceiveChannels
		case .MaxSysExSpeed:
			return kMIDIPropertyMaxSysExSpeed
		case .MaxTransmitChannels:
			return kMIDIPropertyMaxTransmitChannels
		case .ReceiveChannels:
			return kMIDIPropertyReceiveChannels
		case .SingleRealtimeEntity:
			return kMIDIPropertySingleRealtimeEntity
		case .UniqueID:
			return kMIDIPropertyUniqueID
		}
	}
}

extension BooleanProperty: MIDIPropertyNameConvertible {
	public var midiPropertyName: CFStringRef {
		switch self {
		case .CanRoute:
			return kMIDIPropertyCanRoute
		case .IsBroadcast:
			return kMIDIPropertyIsBroadcast
		case .IsDrumMachine:
			return kMIDIPropertyIsDrumMachine
		case .IsEffectUnit:
			return kMIDIPropertyIsEffectUnit
		case .IsEmbeddedEntity:
			return kMIDIPropertyIsEmbeddedEntity
		case .IsMixer:
			return kMIDIPropertyIsMixer
		case .IsSampler:
			return kMIDIPropertyIsSampler
		case .PanDisruptsStereo:
			return kMIDIPropertyPanDisruptsStereo
		case .IsOffline:
			return kMIDIPropertyOffline
		case .IsPrivate:
			return kMIDIPropertyPrivate
		case .SupportsGeneralMIDI:
			return kMIDIPropertySupportsGeneralMIDI
		case .SupportsMMC:
			return kMIDIPropertySupportsMMC
		case .SupportsShowControl:
			return kMIDIPropertySupportsShowControl
		case .TransmitChannels:
			return kMIDIPropertyTransmitChannels
		case .TransmitsBankSelectLSB:
			return kMIDIPropertyTransmitsBankSelectLSB
		case .TransmitsBankSelectMSB:
			return kMIDIPropertyTransmitsBankSelectMSB
		case .TransmitsClock:
			return kMIDIPropertyTransmitsClock
		case .TransmitsMTC:
			return kMIDIPropertyTransmitsMTC
		case .TransmitsNotes:
			return kMIDIPropertyTransmitsNotes
		case .TransmitsProgramChanges:
			return kMIDIPropertyTransmitsProgramChanges
		case .ReceivesBankSelectLSB:
			return kMIDIPropertyReceivesBankSelectLSB
		case .ReceivesBankSelectMSB:
			return kMIDIPropertyReceivesBankSelectMSB
		case .ReceivesClock:
			return kMIDIPropertyReceivesClock
		case .ReceivesMTC:
			return kMIDIPropertyReceivesMTC
		case .ReceivesNotes:
			return kMIDIPropertyReceivesNotes
		case .ReceivesProgramChanges:
			return kMIDIPropertyReceivesProgramChanges
		}
	}
}
