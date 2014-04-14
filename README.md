MIDIKit
=======

This framework aims to take the fuss out of dealing with a C-based, lower-level API (CoreMIDI), and gives you a rich, powerful, object-oriented layer on top, removing the hassle of needing to know the nitty gritty of MIDI (teehee), and letting you transparently interact with the MIDI objects available in an intuitive manner.

###Document Structure
Throughout this document, I will provide very concise examples of key features to whet your appetite and show you the ease and power of `MIDIKit`.

#Table Of Contents
- ###[Examples](#examples)
  - [Objective-C](#objective-c)
  - [JavaScript](#javascript)


- ###[Features](#features-1)
- ###[Classes and Concepts](#classes)

##Examples
I won't go into great depth here; these examples will be fairly brief. However, they should be enough to whet your appetite, and get you playing around with MIDIKit/reading more of the docs.

###Objective-C

```

```

###JavaScript

##Features
- ###**Advanced Objects & I/O, Simplified**
  MIDIKit provides methods for enumerating devices, entities, sources, and destinations, with filtering restrictions, and high-level wrapper classes for every CoreMIDI object type.

- ###**Virtual Endpoints**
It's a breeze to create and utilize virtual sources and destinations with MIDIKit. It is an ideal choice if you're wanting to emulate a MIDI device in software, or create more advanced thru-connections.

- ###**Dynamic, Smart & Hassle-free**
All wrapper objects cache accessed MIDI properties by default. This can be permanently or temporarily disabled, but when it's on, objects automatically invalidate cached properties the instant the MIDI server distributes a notification about it, ensuring every one of your objects is always giving you accurate data.

- ###**Full JavaScript support.**
Yes, this entire framework has been built from the ground up with `JavaScriptCore` at its side. Not only is `MIDIKit` a delight to use in Objective-C, you can take it one step further as to script your own tools for MIDI operations, or even provide that functionality to your users, allowing them and you to create modules which are loaded into the JavaScript runtime. The possibilities are **amazing**.

- ###**Built-In MIDI Parsing & Logic.**
MIDIKit does most of the heavy lifting when it comes to creating data for sending, or parsing data you've received, based on/into something *meaningful*.

```objc
[MKMessage messageWithType:[MKMessage noteOnType]]
```

##Classes & Concepts

###Wrapper
####`Object (MKObject.h)`

  - The main, base wrapper class around CoreMIDI types.
  - Contains native, dynamic getters/setters for all MIDI properties, and methods for custom ones.
  - *Rarely* **ever** will you find yourself instantiating an `MKObject` directly. If you do though, it must be with a unique identifier or CoreMIDI object.


####`Client (MKClient.h)`
  - The important one. You *must* create a client to use this framework.
  - Clients are the parent to ports, which are your pipes for communication.
  - MIDIKit provides the `+[MKClient global]` method which returns a static client, whose name is derivative of the running process information. Typically, however, *it is best practice* to use `+[MKClient clientWithName:]` when possible.


####`Endpoint (MKEndpoint.h)`
  - A unidirectional endpoint, either source or destination.
  - As expected, sources are for receiving input data, destinations are for sending output data.
  - You can create `'virtual'` endpoints which appear on the system exactly like a hardware-representative endpoint would. This is really cool for things like emulating MIDI devices in software.


####`Entity (MKEntity.h)`
  - A device-owned object that contains a set of endpoints
  - You will *rarely* interface with MKEntity to any great extent.


####`Device (MKDevice.h)`
   - A device object, which contains a set of entities.
   - This is the `'root'` object type of hardware components (device owns entities own endpoints).


####`Port(MKInputPort.h, MKOutputPort.h)`
  - A client-owned port through which you communicate with a source or destination.
  - Input ports provide interfaces for delegation AND block-based input callbacks.

---
###MIDIKit I/O Classes
####`Message(MKMessage.h)`
  - A data wrapper class that provides you with a way to construct that data with very little knowledge of how MIDI messages work.
  - Can be subclassed for creating, for example, command messages for a specific device. In my case, I did it for the Novation Launchpad.


####`Connection(MKConnection.h)`
  - A high level convenience I/O session class.
  - Provides unified input/output to multiple sources/destinations.

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
