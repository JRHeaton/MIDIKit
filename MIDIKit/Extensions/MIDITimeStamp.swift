import CoreMIDI

extension MIDITimeStamp {
	public static var Now: MIDITimeStamp = 0
	
	public var secondsAgo: NSTimeInterval {
		let currentTime = mach_absolute_time()
		var timeBaseInfo = mach_timebase_info()
		mach_timebase_info(&timeBaseInfo)
		let nanos = currentTime * numericCast(timeBaseInfo.numer) / numericCast(timeBaseInfo.denom)
		return NSTimeInterval(nanos - self) / 1_000_000_000
	}
	
	public var date: NSDate {
		return NSDate().dateByAddingTimeInterval(-secondsAgo)
	}
}
