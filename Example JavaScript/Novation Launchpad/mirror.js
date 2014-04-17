// some helpers for this script
var LAUNCHPAD_COLORS_MAX = [ 0x3c, 0x7f, 0x0f ]

function randomPadColor(min, max) {
    return LAUNCHPAD_COLORS_MAX[Math.floor(Math.random() * 3)]
}

// -------------------
// create a connection
var connection = MKConnection.withClient(MKClient.named('Launchpad Mirror Fun'))

// loop through all devices
for(var i = 0; i < MKDevice.count(); ++i) {
    // get device object
    var device = MKDevice.atIndex(i)

    // check to make sure the device is online, and a launchpad
    if(device.online && device.name.indexOf('Launchpad') != -1) {

        // set up the connection for output to launchpad
        connection.addDestination(device.rootDestination)

        // set up input port to listen to launchpad
        connection.inputPort.connectSource(device.rootSource)
    }
}


// when we get a button push
connection.inputPort.addInputHandler(function (port, source, message) {
    // if the message is NOT a note-off(user took finger off the button),
    // then make message color a random one, and reuse it for sending back to the devices
    messaage = !message.velocity ? message : message.setVelocity(randomPadColor())

    // send it to all devices, creating a mirror effect
    connection.sendMessage(message)
})

module.exports = connection;