connection = MKConnection.new(); // create a new connection with this process' global client (MKClient.global())
dev = MKDevice.firstContaining('Launchpad'); // first online device whose name contains 'Launchpad'
if(dev.valid) {
	connection.addDestination(dev.rootDestination); // set it up for output
	connection.send([0xb0, 0x00, 0x00]); // send a 'reset' command (Launchpad-specific)
	connection.sendMessage(MKMessage.noteOn(1, 127)); // light up a pad
}
