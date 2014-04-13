//
//  MKJavaScriptContext.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKJavaScriptContext.h"
#import "MKClient.h"
#import "MKConnection.h"

@implementation MKJavaScriptContext {
    BOOL _initialized;
}

- (instancetype)init {
    if(!(self = [super init])) return nil;
    
    [self _setupFancyPantsContext];
    
    return self;
}

- (instancetype)initWithVirtualMachine:(JSVirtualMachine *)virtualMachine {
    if(!(self = [super initWithVirtualMachine:virtualMachine])) return nil;

    return self;
}

- (void)printString:(NSString *)string {
    printf("%s\n", string.UTF8String);
}

- (void)_setupFancyPantsContext {
    void (^logBlock)(NSString *log) = ^(NSString *log) { [self printString:log]; };
    void (^logObjectBlock)(JSValue *val) = ^(JSValue *val) { [self printString:[val.toObject description]]; };

    self[@"_cwd"] = [NSFileManager defaultManager].currentDirectoryPath;
    __weak typeof(self) _self = self;
    self[@"require"] = ^JSValue *(NSString *name) {
        BOOL isScript = [name hasSuffix:@".js"];

        if(isScript) {
            return [_self evaluateScriptAtPath:name];
        }

        return nil;
    };

    NSProcessInfo *info = [NSProcessInfo processInfo];
    self[@"process"] = @{
                         @"exit" : ^(int code) { exit(code); },
                         @"execPath" : [NSBundle mainBundle].executablePath,
                         @"pid" : @(info.processIdentifier),
                         @"cwd" : ^JSValue *() { return _self[@"_cwd"]; },
                         @"chdir" : ^(NSString *dir) { _self[@"_cwd"] = dir; },
                         @"moduleLoadList" : @[],
                         @"env" : info.environment,
                         @"argv" : info.arguments
                         };
    self[@"console"] = @{
                         @"log" : logBlock,
                         @"logObject" : logObjectBlock
                         };
    self[@"log"] = logBlock;
    self[@"logObject"] = logObjectBlock;

    for(NSString *className in @[ @"MKObject",
                                  @"MKClient",
                                  @"MKInputPort",
                                  @"MKOutputPort",
                                  @"MKDevice",
                                  @"MKEntity",
                                  @"MKEndpoint",
                                  @"MKVirtualSource",
                                  @"MKVirtualDestination",
                                  @"MKConnection",
                                  @"MKMessage" ]) {
        [self loadNativeModule:NSClassFromString(className)];
    }

    NSLog(@"FIRSTY %@", self[@"process"][@"moduleLoadList"].toObject);
}

- (JSValue *)evaluateScriptAtPath:(NSString *)name {
    BOOL isValidScript =
    [name hasSuffix:@".js"]
    && [[name lastPathComponent] componentsSeparatedByString:@"."].count > 1
    && [[NSFileManager defaultManager] fileExistsAtPath:name];

    __weak typeof(self) _self = self;
    switch (isValidScript) {
        case YES: {
            if(!name.isAbsolutePath) {
                name = [_self[@"_cwd"].toString stringByAppendingPathComponent:name];
            }

            NSError *e;
            static NSString *evalFmt = @"(function (){ var module = {exports:{}}; var exports = module.exports; var obj = (function (){ %@ })(); return module.exports; })()";
            NSString *eval = [NSString stringWithFormat:evalFmt, [NSString stringWithContentsOfFile:name encoding:NSUTF8StringEncoding error:&e]];

            if(e) {
                [_self printString:[NSString stringWithFormat:@"Error loading script: \'%@\'", name]];
                return nil;
            }
            JSValue *val = [_self evaluateScript:eval];

            static NSString *clearModule = @"delete module";
            [_self evaluateScript:clearModule];

            if(!val) {
                [_self printString:[NSString stringWithFormat:@"Error evaluating script: \'%@\', error = %@", name, e]];
            } else {
                NSLog(@"%@", self[@"process"].toObject);
                [_self evaluateScript:[NSString stringWithFormat:@"process.moduleLoadList.push(\'Script %@\');", name.lastPathComponent]];
            }

            return val;
        } break;
        case NO: {

        } break;
    }

    return nil;
}

- (BOOL)loadNativeModuleAtPath:(NSString *)path {
    return NO;
}

- (JSValue *)loadNativeModule:(Class<MKJavaScriptModule>)module {
    NSString *className = NSStringFromClass(module);
    if(![self[className] isUndefined]) return nil;

    static NSString *script = @"process.moduleLoadList.push(\'NativeModule %@\');";
    NSString *formatted = [NSString stringWithFormat:script, className];

    [self evaluateScript:formatted];
    self[className] = module;

    return self[className];
}

@end
