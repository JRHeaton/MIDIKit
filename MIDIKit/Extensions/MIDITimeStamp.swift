import CoreMIDI
import CoreAudio

extension MIDITimeStamp {
	public static var Now: MIDITimeStamp = 0
	
	public var secondsAgo: NSTimeInterval {
		return NSTimeInterval(AudioConvertHostTimeToNanos(AudioGetCurrentHostTime() - self)) / 1_000_000_000
	}
	
	public var date: NSDate {
		return NSDate().dateByAddingTimeInterval(-secondsAgo)
	}
}
