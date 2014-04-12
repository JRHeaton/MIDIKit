var client = MKClient.clientWithName("my client");
var connection = MKConnection.connectionWithClient(client);

connection.addDestination(MKEndpoint.firstOnlineDestinationNamed("Launchpad Mini 4"));
connection.sendMessages([LPMessage.setLayoutXY(), LPMessage.LEDTest()]);