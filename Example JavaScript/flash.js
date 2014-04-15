LPMessage = Object.create(MKMessage);
LPMessage.reset = function() {
    return MKMessage.controlChange(0, 0);
}
LPMessage.lightAll = function() {
    return MKMessage.controlChange(0, 0x7f);
}

connection = MKConnection.new();                        // create a new connection with this process' global client (MKClient.global())
dev = MKDevice.firstContaining('Launchpad');            // first online device whose name contains 'Launchpad'
if(dev.valid) {                                         // if device holds a valid MIDI reference
	connection.addDestination(dev.rootDestination);     // set it up for output

    connection.reset = function() { this.sendMessage(LPMessage.reset()); }
    connection.light = function() { this.sendMessage(LPMessage.lightAll()); }

    MIDIKit.after(3, function() {
                  connection.light();
    })
//    connection.reset();
//    connection.sendMessage(MKMessage.noteOn(0, 127));   // light up the whole device
//    
//    connection.sendMessage(LPMessage.lightAll());          // send a 'reset' command (Launchpad-specific)
}

return connection;