var client = MKClient.new()
var lp = MKEndpoint.firstOnlineDestinationNamed('Launchpad Mini 4');
var port = client.firstOutputPort();

var msg = LPMessage.reset();

port.sendMessage(msg, lp);