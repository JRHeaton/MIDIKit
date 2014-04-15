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

        __weak typeof(c) _c = c;
        __block NSUInteger currentLine = 0;
        c.exceptionHandler = ^(JSContext *context, JSValue *exception) {

            printf("%s", [NSString stringWithFormat:@"\033[1;32m~> %@\033[1;31m%@\033[0m\n", !currentLine ? @"" : [NSString stringWithFormat:@"Line %lu: ", (unsigned long)currentLine], [NSString stringWithFormat:@"Line %d: %@", [[exception.toObject objectForKey:@"line"] intValue], exception]].UTF8String);
        };

        NSString *execPath = [NSBundle mainBundle].executablePath;
        execPath = [execPath substringToIndex:execPath.length - execPath.lastPathComponent.length];

        if(argc > 2) {
            NSLog(@"using argv[1]...");

            c.currentEvaluatingScriptPath = [NSString stringWithUTF8String:argv[1]];
        } else {
            NSLog(@"using SRCROOT..."); // defined by -DSRCROOT="\"${SRCROOT}\"" in build settings
            c.currentEvaluatingScriptPath = [[NSString stringWithUTF8String:SRCROOT] stringByAppendingPathComponent:@"Example JavaScript"];
        }
        c[@"unitTests"] = ^{ runTestScript(_c, @"unitTest.js"); };
        c[@"launchpad"] = ^{ runTestScript(_c, @"launchpad.js"); };
        c[@"help"] = @"\nrequire(path)   -- evaluate a script\nlocal()         -- set relative path for require() calls\nshowEval(bool)  -- set whether return values should be printed\nprocess         -- global process object";

        c[@"require"] = ^JSValue *(NSString *path) {
            NSString *evalPath = [_c[@"__dirname"] toString];
            if([path hasPrefix:@"./"] || ![path hasPrefix:@"/"])
                path = [evalPath stringByAppendingPathComponent:path];

            if(![path hasSuffix:@".js"] && [path.lastPathComponent componentsSeparatedByString:@"."].count == 1) {
                path = [path stringByAppendingString:@".js"];
            }

            if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [_c evaluateScript:[NSString stringWithFormat:@"throw new Error('Script does not exist: %@')", path]];
                return [JSValue valueWithUndefinedInContext:_c];
            }

            NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            if(s.length) {
                return [_c evaluateScript:[NSString stringWithFormat:
                                           @"(function() { "
                                           "    var exports; "
                                           "    (function () { "
                                           "        %@ "
                                           "    })(); "
                                           "    return exports; "
                                           "})()",
                                           s]];
            }

            return [JSValue valueWithUndefinedInContext:_c];
        };
        c[@"local"] = ^JSValue *{ _c[@"__dirname"] = [_c evaluateScript:@"process.cwd()"]; return _c[@"__dirname"]; };

        __block BOOL showEval = YES;
        c[@"showEval"] = ^(BOOL show) { showEval = show; };

        
        if(![NSProcessInfo processInfo].environment[@"REPL"]) {
            printf("to run in REPL mode, set env var REPL=1\n");
            // standard exec

            NSLog(@"%@", [c evaluateScript:@"require('asd')"]);

            return 0;
        }

        using_history();
#define hist [@"~/.midirepl_history" stringByExpandingTildeInPath].UTF8String
        signal(SIGINT, [](int) -> void {
            write_history(hist);
            exit(0);
        });

        read_history(hist);
        while(1) {
            const char *buf = readline("\033[1;34m|> \033[0m");

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