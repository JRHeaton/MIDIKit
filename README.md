MIDIKit
=======

This framework aims to be a convenience/wrapper framework around CoreMIDI, a lower-level C API for MIDI I/O on Mac OS X. This framework provides a lightweight and convenient way to wrap CoreMIDI objects, but can also be used with little to no knowledge of CoreMIDI itself.


Before we get technical, let's dive into a quick example.
```objc
    MKClient *client = [MKClient clientWithName:@"My MIDI Client"];
    MKEndpoint *lp = [MKEndpoint firstDestinationMeetingCriteria:^BOOL(MKEndpoint *candidate) {
        return candidate.online && [candidate.name isEqualToString:@"Launchpad Mini"];
    }];
```

In just a few lines of code, I've created a client to the system MIDI server, enumerated through all available MIDI destinations(output endpoints), and filtered out the one I want: my [Novation Launchpad Mini](http://global.novationmusic.com/midi-controllers-digital-dj/launchpad-mini). This device has a public reference manual for how to control the LED matrix with MIDI messages.

Now that I have a wrapper object of the output to my Launchpad, I want to send some data.
```objc
    UInt8 msg[3] = { 0xb0, 0x00, 0x7f }; // Test command, lights up all LEDs
    MKOutputPort *outputPort = client.createOutputPort;
    [outputPort sendData:[NSData dataWithBytes:msg length:3] toDestination:lp];
```

It's that easy. The client object can manage one or more input ports, output ports, virtual destinations, and virtual sources. In this instance, we created one new output port, which will now be stored in `client.outputPorts`, and used it to send our data to the destination we got earlier.

![LED Test](https://i.cloudup.com/VKYR25uWJb.jpeg)