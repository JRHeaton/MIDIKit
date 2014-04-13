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

@implementation MKJavaScriptContext

- (instancetype)init {
    if(!(self = [super init])) return nil;
    
    [self setup];
    
    return self;
}

- (instancetype)initWithVirtualMachine:(JSVirtualMachine *)virtualMachine {
    if(!(self = [super initWithVirtualMachine:virtualMachine])) return nil;

    [self setup];

    return self;
}

- (void)printString:(NSString *)string {
    printf("%s\n", string.UTF8String);
}

- (void)setup {
    void (^logBlock)(NSString *log) = ^(NSString *log) { [self printString:log]; };
    void (^logObjectBlock)(JSValue *val) = ^(JSValue *val) { [self printString:[val.toObject description]]; };

    __weak typeof(self) _self = self;
    self[@"require"] = ^JSValue *(NSString *name) {
        BOOL isScript = [name hasSuffix:@".js"];

        switch (isScript && [[name lastPathComponent] componentsSeparatedByString:@"."].count > 1) {
            case YES: {
                if(!name.isAbsolutePath) {
                    name = [[NSFileManager defaultManager].currentDirectoryPath stringByAppendingPathComponent:name];
                }

                NSError *e;
                static NSString *evalFmt = @"(function (){ var module = {exports:{}}; var exports = module.exports; var obj = (function (){ %@ })(); return module.exports; })()";
                NSString *eval = [NSString stringWithFormat:evalFmt, [NSString stringWithContentsOfFile:name encoding:NSUTF8StringEncoding error:&e]];
                JSValue *val = [_self evaluateScript:eval];

                static NSString *clearModule = @"delete module";
                [_self evaluateScript:clearModule];

                if(e || !val) {
                    [_self printString:[NSString stringWithFormat:@"Error loading script \'%@\': %@", name, e]];
                }

                return val;
            } break;
            case NO: {
                
            } break;
        }

        return nil;
    };
    self[@"process"] = @{
                         @"exit" : ^(int code) { exit(code); },
                         @"execPath" : [NSBundle mainBundle].executablePath,
                         @"pid" : @([NSProcessInfo processInfo].processIdentifier),
                         @"cwd" : [[NSFileManager defaultManager] currentDirectoryPath]
                         };
    self[@"console"] = @{ @"log" : logBlock, @"logObject" : logObjectBlock };
    self[@"log"] = logBlock;
    self[@"logObject"] = logObjectBlock;
    self[@"moduleLoadList"] = @[];

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
        self[className] = NSClassFromString(className);
    }
}

@end
