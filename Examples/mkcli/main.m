//
//  main.m
//  mkcli
//
//  Created by John Heaton on 4/13/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIKit.h"
#import <readline/readline.h>

void runTestScript(MKJavaScriptContext *c, NSString *name) {
    [c require:name];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MKJavaScriptContext *c = [MKJavaScriptContext new];
        c.currentEvaluatingScriptPath = @"/Users/John/Dropbox/Developer/projects/MIDIKit/Examples/mkcli/scripts";

        __weak typeof(c) _c = c;
        c[@"unitTests"] = ^{ runTestScript(_c, @"unitTest.js"); };
        c[@"launchpad"] = ^{ runTestScript(_c, @"launchpad.js"); };

        if(![NSProcessInfo processInfo].environment[@"REPL"]) {
            printf("to run in REPL mode, set env var REPL=1\n");
            // standard exec
            return 0;
        }

        c.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            printf("> %s\n", exception.description.UTF8String);
        };
        while(1) {
            const char *buf = readline("] ");

            printf("> %s\n", [[c evaluateScript:[NSString stringWithUTF8String:buf]].toObject description].UTF8String);
        }

//        runTestScript(c, @"unitTest.js");
//        runTestScript(c, @"launchpad.js");


//        CFRunLoopRun();
    }
    return 0;
}