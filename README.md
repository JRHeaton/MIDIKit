MIDIKit
=======

This framework aims to be a convenience/wrapper framework around CoreMIDI, a lower-level C API for MIDI I/O on Mac OS X. This framework provides a lightweight and convenient way to wrap CoreMIDI objects, but can also be used with little to no knowledge of CoreMIDI itself.


Before we get technical, let's dive into a quick example.
```objc
    MKClient *client = [MKClient clientWithName:@"My MIDI Client"];
    MKEndpoint *lp = [MKEndpoint firstDestinationMeetingCriteria:^BOOL(MKEndpoint *candidate) {
        return candidate.online && [candidate.name isEqualToString:@"Launchpad S"];
    }];
```

In just a few lines of code, I've created a client to the system MIDI server, enumerated through all available MIDI destinations(output endpoints), and filtered out the one I want: my [Novation Launchpad S](http://global.novationmusic.com/midi-controllers-digital-dj/launchpad-s). This device has a public reference manual for how to control the LED matrix with MIDI messages.

Now that I have a wrapper object of the output to my Launchpad, I want to send some data.
```objc
    MKOutputPort *outputPort = [client createOutputPort];
    [outputPort sendData:[NSData dataWithBytes:msg length:3] toEnd]
```