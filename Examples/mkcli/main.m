//
//  main.m
//  mkcli
//
//  Created by John Heaton on 4/13/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIKit.h"
#import "LPMessage.h"
#import <readline/readline.h>

void runTestScript(MKJavaScriptContext *c, NSString *name) {
    [c require:name];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MKJavaScriptContext *c = [MKJavaScriptContext new];

        NSString *execPath = [NSBundle mainBundle].executablePath;
        execPath = [execPath substringToIndex:execPath.length - execPath.lastPathComponent.length];

        if(argc > 2) {
            NSLog(@"using argv[1]...");

            c.currentEvaluatingScriptPath = [NSString stringWithUTF8String:argv[1]];
        } else {
            NSLog(@"using SRCROOT...");
            c.currentEvaluatingScriptPath = [[NSString stringWithUTF8String:SRCROOT] stringByAppendingPathComponent:@"Examples/mkcli/scripts"];
        }

        [c loadNativeModule:[LPMessage class]];
        __weak typeof(c) _c = c;
        c[@"unitTests"] = ^{ runTestScript(_c, @"unitTest.js"); };
        c[@"launchpad"] = ^{ runTestScript(_c, @"launchpad.js"); };

        c[@"local"] = ^{ _c[@"__dirname"] = [_c evaluateScript:@"process.cwd()"]; };
        if(![NSProcessInfo processInfo].environment[@"REPL"]) {
            printf("to run in REPL mode, set env var REPL=1\n");
            // standard exec
            return 0;
        }

        __block BOOL showEval = YES;
        c[@"showEval"] = ^(BOOL show) { showEval = show; };

        c.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            printf("> %s\n", exception.description.UTF8String);
        };
        while(1) {
            const char *buf = readline("] ");

            if(!buf || !strlen(buf)) continue;
            add_history(buf);

            JSValue *val = [c evaluateScript:[NSString stringWithUTF8String:buf]];
            if(showEval)
                printf("> %s\n", [val.toObject description].UTF8String);
        }

//        runTestScript(c, @"unitTest.js");
//        runTestScript(c, @"launchpad.js");


//        CFRunLoopRun();
    }
    return 0;
}