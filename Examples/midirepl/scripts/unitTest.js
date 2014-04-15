// JavaScript unit tests for MIDIKit bridge
// ----------------------------------------

// Helpers
function runTest(name, imp) {
    log('********** Running Test: \'' + name + '\' **********');
    imp();
    log('----------------------------------------------------------');
}

function testBadValue(val) {
    return (val === null || val === undefined) ? "FAIL" : "PASS";
}

function badValTestNamed(name, val, tester) {
    var logStr = '[' + testBadValue(val) + '] ' + '~ [<' + name + '>]';
    if(tester) logStr = logStr + '\n\t-- (tested with ' + tester + ')';

    log(logStr);
}

// Tests
runTest('Multiple Inheritance', function () {
    badValTestNamed('Double', MKVirtualSource.named, 'MKVirtualSource.named');
    badValTestNamed('Direct', MKVirtualSource.withUniqueID, 'MKVirtualSource.withUniqueID (from MKObject)');
})