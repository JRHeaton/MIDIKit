// ---------------------------------------------------------------------
// script.js
//
// This script will illuminate one red pad at grid position(0, 0)
// and light up the rest of the grid in bright yellow.
// The yellow pads will blink on and off, hence the flash.
//
// If you evalute this script into a JSContext, you'll have a reference
// to the MKConnection object, on which there is a reset() method
// you can use to bring your device back to a cleared state.
// ---------------------------------------------------------------------


// Create a subclass of MKMessage for Launchpad-specific messages
LPMessage = Object.create(MKMessage)

// add methods which implement command logic

// reset the device grids
LPMessage.reset = function() {
    return MKMessage.controlChange(0, 0)
}

// light up the entire grid
LPMessage.lightAll = function() {
    return MKMessage.controlChange(0, 0x7f)
}

// enable flashing (buffer switching automatically)
LPMessage.flash = function() {
    return MKMessage.message(0xb0, 0, 0x28);
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
    connection.notePadExample = function() {
        this.sendMessages([MKMessage.noteOn(0, 0x0f), LPMessage.flash()])
    }
}

// call it, and let there be light!
connection.reset()
connection.light()
connection.notePadExample()

// if evaluated directly into a JSContext with an enclosing function wrapper, this will be the return value
module.exports = connection;