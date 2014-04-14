// Test JS module that wraps an MKConnection,
// and provides convenient methods for sending
// LPMessage objects, an MKMessage subclass which
// implements Novation Launchpad commands.

function LPConnection(name) {
    this.connection = MKConnection.new();

    if(!name) name = 'Launchpad';
    this.name = name;

    this.Find()
}

LPConnection.prototype.Find = function () {
    this.launchpad = MKEndpoint.firstDestinationContaining(this.name);
    this.connection.destinations = [];
    this.connection.addDestination(this.launchpad);
}

LPConnection.prototype.Test = function () {
    this.connection.sendMessage(MKMessage.messageWithType(MKMessage.controlChangeType()).setByteAtIndex(0x7d, 2));
    return this;
}

LPConnection.prototype.Reset = function () {
    this.connection.sendMessage(MKMessage.message(0xb0, 0x00, 0x00));
    return this;
}

module.exports = LPConnection;