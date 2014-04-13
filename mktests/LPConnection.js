// Test JS module that wraps an MKConnection,
// and provides convenient methods for sending
// LPMessage objects, an MKMessage subclass which
// implements Novation Launchpad commands.

module.exports = function (name) {
    this.connection = MKConnection.new();

    if(!name) name = 'Launchpad Mini 4';
    this.name = name;

    this.Find()
}

module.exports.prototype.Find = function () {
    this.launchpad = MKEndpoint.firstOnlineDestinationNamed(this.name);
    this.connection.destinations = [];
    this.connection.addDestination(this.launchpad);
}

module.exports.prototype.Test = function () {
    this.connection.sendMessage(LPMessage.LEDTest());
    return this;
}

module.exports.prototype.Reset = function () {
    this.connection.sendMessage(LPMessage.reset());
    return this;
}