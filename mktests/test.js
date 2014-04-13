var msg = require('/Users/John/Dropbox/Developer/projects/MIDIKit/mktests/msg.js')

var client = MKClient.new();
client.firstOutputPort().sendMessage(msg.Reset(), MKEndpoint.firstOnlineDestinationNamed('Launchpad Mini 4'));
