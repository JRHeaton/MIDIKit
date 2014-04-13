//var LPConnection = require('/Users/John/Dropbox/Developer/projects/MIDIKit/mktests/LPConnection.js')
//var Launchpad = new LPConnection();
//Launchpad.Reset()

var native = require('./testNativeModule.dylib');

console.log('LPMessage.reset: ' + LPMessage.reset);

console.log('native: ' + native)
log(testNativeModule)
log(testNativeModule.doThingy)
log(testNativeModule.doThingy())

log('Loading bundle.........');
var bundle = require('./testNativeBundle.bundle');

log('bundle: ' + bundle);
log('bundle class: ' + JRNativeBundle);