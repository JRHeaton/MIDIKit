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
    NSLog(@"%@", [c require:name]);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MKJavaScriptContext *c = [MKJavaScriptContext new];
        c.currentEvaluatingScriptPath = @"/Users/John/Dropbox/Developer/projects/MIDIKit/Examples/mkcli/scripts";

#define RUN_REPL 0

        c.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            printf("> %s\n", exception.description.UTF8String);
        };
#if RUN_REPL == 1
        while(1) {
            const char *buf = readline("] ");

            printf("> %s\n", [[c evaluateScript:[NSString stringWithUTF8String:buf]].toObject description].UTF8String);
        }

#else
//        runTestScript(c, @"unitTest.js");
        runTestScript(c, @"launchpad.js");

#endif

//        CFRunLoopRun();
    }
    return 0;
}