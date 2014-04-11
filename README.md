MIDIKit
=======

This framework aims to be a convenience/wrapper framework around CoreMIDI, a lower-level C API for MIDI I/O on Mac OS X. This framework provides a lightweight and convenient way to wrap CoreMIDI objects, but can also be used with little to no knowledge of CoreMIDI itself.

##To Do
Name| Status
----|-------
MIDI File Parsing | Incomplete

##What works
- Enumerating devices, sources, destinations, and entities.
- Creating and disposing wrappers for all CoreMIDI object types
- Input/Output to MIDI devices via ports (or connections)
- Creating and using virtual endpoints
- Receiving updates about the MIDI system state

#Concepts
- `Object(MKObject.h)` - The main, base wrapper class around CoreMIDI types.
- `Client(MKClient.h)` - The important one. You *must* create a client to use this framework.
- `Endpoint(MKEndpoint.h)` - A unidirectional endpoint, either source or destination.
- `Entity(MKEntity.h)` - Contains a set of endpoints
- `Device(MKDevice.h)` - A device, which contains a set of entities.
- `Port(MK{Input/Output}Port.h)` - A client-owned port through which you communicate with a source or destination.
- `Message(MKMessage.h)` - Essentially a data wrapper class that implements logic for MIDI messages. Subclass this for specific devices.
- `Connection(MKConnection.h)` - A high level convenience class for I/O to multiple sources/destinations.

Before we get technical, let's dive into a quick example.
```objc
MKClient *client = [MKClient clientWithName:@"MyMIDIClient"];
MKEndpoint *lp = [MKEndpoint firstDestinationMeetingCriteria:^BOOL(MKEndpoint *candidate) {
    return candidate.online && [candidate.name isEqualToString:@"Launchpad Mini"];
}];
```

In just a few lines of code, I've created a client to the system MIDI server, enumerated through all available MIDI destinations(output endpoints), and filtered out the one I want: my [Novation Launchpad Mini](http://global.novationmusic.com/midi-controllers-digital-dj/launchpad-mini). This device has a public reference manual for how to control the LED matrix with MIDI messages.

Now that I have a wrapper object of the output to my Launchpad, I want to send some data.
```objc
UInt8 msg[3] = { 0xb0, 0x00, 0x7f }; // Test command, lights up all LEDs
MKOutputPort *outputPort = client.createOutputPort;
[client.firstOutputPort sendData:[NSData dataWithBytes:msg length:3] toDestination:lp];
```

It's that easy. The client object can manage one or more input ports, output ports, virtual destinations, and virtual sources. In this instance, we created one new output port, which will now be stored in `client.outputPorts`, and used it to send our data to the destination we got earlier.

##BUT I LIKE PRESSING BUTTONS
And MIDIKit will let me detect that. Just as there are output ports, there are input ports. You can simply instantiate one with `-[MKClient createInputPort]` or (more intelligently) `-[MKClient firstInputPort]`. The latter will only create a new port if there isn't one already.

But *how*?
```objc
@interface CoolMIDIApp : NSMcNugget <MKInputPortDelegate>
@end

@implementation CoolMIDIApp

- (void)inputPort:(MKInputPort *)inputPort
     receivedData:(NSData *)data
       fromSource:(MKEndpoint *)source {
    NSLog(@"Got data of length %lu on port %@ from source %@", data.length, inputPort.name, source.name);
}

@end
```

We can leverage this `MKInputPortDelegate` protocol to assign one or more object instances as delegates to input events on the input port.
```objc
CoolMIDIApp *app = ...;
MKInputPort *inputPort = ...;

[inputPort addInputDelegate:app];
```

And now in the console, as I press buttons...
```
Got data of length 3 on port MyMIDIClient-Input-0 from source Launchpad Mini 4
```

#Alternative Method (MKConnection)
`MKConnection` is a great high level class that will make your life easy when it comes to communicating with MIDI endpoints.

You can create a connection like so; it will make sure ports are set up for input/output. You give it some destination(s), and you can send data!
```objc
MKClient *client = [MKClient clientWithName:@"MyMIDIClient"];
MKConnection *conn = [MKConnection connectionWithClient:client];
[conn addDestination:[MKEndpoint firstDestinationMeetingCriteria:^BOOL(MKEndpoint *candidate) {
    return candidate.online && [candidate.name isEqualToString:@"Launchpad Mini"];
}]];

[conn sendData:myData];
```

![LED Test](https://i.cloudup.com/VKYR25uWJb.jpeg)