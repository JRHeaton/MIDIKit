var client = MKClient.new()
var lp = MKEndpoint.firstOnlineDestinationNamed('Launchpad Mini 4');
var port = client.firstOutputPort();

var msg = LPMessage.reset();

port.sendMessages(MKMessage.messages(0x90, 0x30, 127, 0x90, 0x31, 31), lp);