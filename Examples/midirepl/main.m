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
#import <AppKit/AppKit.h>

JSValue *runTestScript(MKJavaScriptContext *c, NSString *name) {
    return [c require:name];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MKJavaScriptContext *c = [MKJavaScriptContext new];
        c[@"LPMessage"] = [LPMessage class];

        NSString *execPath = [NSBundle mainBundle].executablePath;
        execPath = [execPath substringToIndex:execPath.length - execPath.lastPathComponent.length];

        if(argc > 2) {
            NSLog(@"using argv[1]...");

            c.currentEvaluatingScriptPath = [NSString stringWithUTF8String:argv[1]];
        } else {
            NSLog(@"using SRCROOT..."); // defined by -DSRCROOT="\"${SRCROOT}\"" in build settings
            c.currentEvaluatingScriptPath = [[NSString stringWithUTF8String:SRCROOT] stringByAppendingPathComponent:@"Examples/midirepl/scripts"];
        }
        __weak typeof(c) _c = c;
        c[@"unitTests"] = ^{ runTestScript(_c, @"unitTest.js"); };
        c[@"launchpad"] = ^{ runTestScript(_c, @"launchpad.js"); };
        c[@"help"] = @"\nscript(path)    -- evaluate a script\nlocal()         -- set relative path for script() calls\nshowEval(bool)  -- set whether return values should be printed\nprocess         -- global process object";

        c[@"script"] = ^JSValue *(NSString *path) {
            NSString *evalPath = [_c[@"__dirname"] toString];
            if([path hasPrefix:@"./"])
                path = [evalPath stringByAppendingPathComponent:path];

            NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            if(s.length) {
                return [_c evaluateScript:[NSString stringWithFormat:@"(function () { %@ })()", s]];
            }

            return [JSValue valueWithUndefinedInContext:_c];
        };
        c[@"local"] = ^JSValue *{ _c[@"__dirname"] = [_c evaluateScript:@"process.cwd()"]; return _c[@"__dirname"]; };
        if(![NSProcessInfo processInfo].environment[@"REPL"]) {
            printf("to run in REPL mode, set env var REPL=1\n");
            // standard exec

            return 0;
        }

        __block BOOL showEval = YES;
        c[@"showEval"] = ^(BOOL show) { showEval = show; };

        c.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            printf("\033[1;32m~> \033[1;31m%s\033[0m\n", exception.description.UTF8String);
        };
        while(1) {
            const char *buf = readline("\033[1;34m] \033[0m");

            if(!buf || !strlen(buf)) continue;
            add_history(buf);

            JSValue *val;
            @try {
                val = [c evaluateScript:[NSString stringWithUTF8String:buf]];

                if(showEval) {
                    const char *print = NULL;

                    BOOL isBadVal = (val.isUndefined || val.isNull);
                    if(isBadVal) {
                        print = val.isUndefined ? "[undefined]" : "[null]";
                    } else {
                        id objVal = val.toObject;
                        if([objVal isKindOfClass:[NSDictionary class]] && ![(NSDictionary *)objVal count]) {
                            print = [val description].UTF8String;
                        } else {
                            print = [objVal description].UTF8String;
                        }
                    }
                    printf("\033[1;32m~> \033[0;36m%s\n\033[0m", print);
                }
            }
            @catch (NSException *exception) {
                NSLog(@"ObjC exception thrown: %@", exception);
            }
        }

//        CFRunLoopRun();
    }
    return 0;
}