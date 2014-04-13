//var LPConnection = require('/Users/John/Dropbox/Developer/projects/MIDIKit/mktests/LPConnection.js')
//var Launchpad = new LPConnection();
//Launchpad.Reset()

var native = require('/Users/John/Dropbox/Developer/projects/MIDIKit/DerivedData/MIDIKit/Build/Products/Debug/testNativeModule.dylib');

console.log('native: ' + native)
log(testNativeModule)
log(testNativeModule.doThingy)
log(testNativeModule.doThingy())

log('Loading bundle.........');
var bundle = require('/Users/John/Dropbox/Developer/projects/MIDIKit/DerivedData/MIDIKit/Build/Products/Debug/testNativeBundle.bundle');

log('bundle: ' + bundle);
log('bundle class: ' + JRNativeBundle);