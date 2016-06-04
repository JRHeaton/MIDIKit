//
//  Properties.swift
//  hax
//
//  Created by John Heaton on 5/14/16.
//  Copyright © 2016 John Heaton. All rights reserved.
//

public enum StringProperty {
	case DisplayName
	case DriverDeviceEditorApp
	case DriverOwner
	case DeviceImagePath
	case Manufacturer
	case Model
	case Name
}

public enum IntegerProperty {
	case AdvanceScheduleTimeMuSec
	case ConnectionUniqueID
	case DeviceID
	case DriverVersion
	case MaxReceiveChannels
	case MaxSysExSpeed
	case MaxTransmitChannels
	case ReceiveChannels
	case SingleRealtimeEntity
	case UniqueID
}

public enum BooleanProperty {
	case CanRoute
	case IsBroadcast
	case IsDrumMachine
	case IsEffectUnit
	case IsEmbeddedEntity
	case IsMixer
	case IsSampler
	case PanDisruptsStereo
	case IsOffline
	case IsPrivate
	case SupportsGeneralMIDI
	case SupportsMMC
	case SupportsShowControl
	case TransmitChannels
	case TransmitsBankSelectLSB
	case TransmitsBankSelectMSB
	case TransmitsClock
	case TransmitsMTC
	case TransmitsNotes
	case TransmitsProgramChanges
	case ReceivesBankSelectLSB
	case ReceivesBankSelectMSB
	case ReceivesClock
	case ReceivesMTC
	case ReceivesNotes
	case ReceivesProgramChanges
}

public enum DataProperty {
	case ConnectionUniqueID
}

public enum DictionaryProperty {
	case PropertyNameConfiguration
}
