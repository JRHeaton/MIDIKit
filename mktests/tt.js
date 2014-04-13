module.exports.Setup = function (client) {
    module.exports.dest = MKEndpoint.firstOnlineDestinationNamed('Launchpad Mini 4');
    module.exports.client = client;
    return this;
}

module.exports.Reset = function () {
    exports.client.firstOutputPort().sendMessage(LPMessage.reset(), module.exports.dest);
    return this;
}

exports.Test = function () {
    exports.client.firstOutputPort().sendMessage(LPMessage.LEDTest(), module.exports.dest);
    return this;
}
