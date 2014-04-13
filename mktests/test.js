function runTest(name, imp) {
    log('********** Running Test: \'' + name + '\' **********');
    imp();
    log('----------------------------------------------------------');
}

function testBadValue(val) {
    return (val === null || val === undefined) ? "FAIL" : "PASS";
}

function badValTestNamed(name, val, tester) {
    var logStr = '[' + testBadValue(val) + '] ' + '[<' + name + '>]';
    if(tester) logStr = logStr + ' (tested with ' + tester + ')';

    log(logStr);
}

runTest('Multiple Inheritance', function () {
    badValTestNamed('Double', MKVirtualSource.objectWithUniqueID, 'MKVirtualSource -> MKEndpoint -> MKObject.objectWithUniqueID');
    badValTestNamed('Single', MKVirtualSource.numberOfSources, 'MKEndpoint -> MKObject.numberOfSources');
    badValTestNamed('Direct', MKVirtualSource.virtualSourceNamed, 'MKVirtualSource.virtualSourceNamed');
})

runTest('Native Module (Dylib)', function () {
    var dylib = require('./testNativeModule.dylib');

    badValTestNamed('Module loads successfully', dylib, 'require(\'./testNativeModule.dylib\')');
    badValTestNamed('Module class: ' + testNativeModule, dylib)
    badValTestNamed('Module function: ' + testNativeModule.someNumber(), testNativeModule.someNumber, 'testNativeModule.someNumber()')
    badValTestNamed('Module instance: ' + testNativeModule.new(), testNativeModule.new, 'testNativeModule.new()')
    badValTestNamed('require() return value: ' + dylib, dylib)
})

runTest('Native Module (Bundle)', function () {
    var bundle = require('./testNativeBundle.bundle');

    badValTestNamed('Module loads successfully', bundle, 'require(\'./testNativeBundle.bundle\')');
    badValTestNamed('Module class: ' + JRNativeBundle, bundle)
    badValTestNamed('Module function: ' + JRNativeBundle.someNumber(), JRNativeBundle.someNumber, 'JRNativeBundle.someNumber()')
    badValTestNamed('Module instance: ' + JRNativeBundle.new(), JRNativeBundle.new, 'JRNativeBundle.new()')
    badValTestNamed('require() return value: ' + bundle, bundle)
})