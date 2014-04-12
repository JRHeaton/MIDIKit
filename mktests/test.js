output = firstOnlineDestinationNamed('Launchpad Mini 4');
input = firstOnlineSourceNamed('Launchpad Mini 4')
client.firstInputPort().connectSource(input)

var buttons = [ 4, 5, 6, 7 ];
var matchedButtons = [];

client.firstInputPort().inputHandler = function (dataArray) {
    var down = dataArray[2] > 0;
    if(!down)
        return;
    
    if(buttons.indexOf(dataArray[1]) != -1) {
        matchedButtons.push(1);
    }
    
    if(matchedButtons.length == 4) {
        // you've won
        client.firstOutputPort().send([0xb0, 0x00, 0x7f], output);
    }
}