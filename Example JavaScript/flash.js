// Create a subclass of MKMessage for Launchpad-specific messages
LPMessage = Object.create(MKMessage)

// add methods which implement command logic
LPMessage.reset = function() {
    return MKMessage.controlChange(0, 0)
}
LPMessage.lightAll = function() {
    return MKMessage.controlChange(0, 0x7f)
}

// create a new connection with this process' global client (MKClient.global())
connection = MKConnection.new()

// first online device whose name contains 'Launchpad'
dev = MKDevice.firstContaining('Launchpad')

// if device holds a valid MIDI reference
if(dev.valid) {
    // set it up for output
    connection.addDestination(dev.rootDestination)

    // conveniently set up some functions on this connection object
    connection.reset = function() { this.sendMessage(LPMessage.reset()) }
    connection.light = function() { this.sendMessage(LPMessage.lightAll()) }
    connection.notePadExample = function() { this.sendMessage(MKMessage.noteOn(0, 0x0f)) }

    // call it, and let there be light!
    connection.reset()
    connection.light()
    connection.notePadExample()

    // enable flashing (buffer switching automatically)
    // this is another way to make a message
    connection.sendMessage(LPMessage.message(0xb0, 0x00, 0x28));
}

// if evaluated directly into a JSContext with an enclosing function wrapper, this will be the return value
return connection
