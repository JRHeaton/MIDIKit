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
#import "MIDIKit.h"
#import <dlfcn.h>
#import <objc/runtime.h>

@implementation MKJavaScriptContext {
    BOOL _initialized;
    NSMutableSet *loadedModules;

    JSValue *(^_requireBlock)(NSString *name);
}

- (instancetype)init {
    if(!(self = [super init])) return nil;
    
    [self _setupFancyPantsContext];
    loadedModules = [NSMutableSet new];
    
    return self;
}

- (void)printString:(NSString *)string {
    printf("%s\n", string.UTF8String);
}

- (void)classesLoaded:(NSNotification *)notif {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notif.name object:notif.object];
    NSArray *classes = notif.userInfo[NSLoadedClasses];

    for(NSString *className in classes) {
        [self loadNativeModule:NSClassFromString(className)];
    }
}

- (void)setCurrentEvaluatingScriptPath:(NSString *)currentEvaluatingScriptPath {
    self[@"__dirname"] = currentEvaluatingScriptPath;
}

- (NSString *)currentEvaluatingScriptPath {
    return [self[@"__dirname"] toString];
}

- (JSValue *)require:(NSString *)path {
    return _requireBlock(path);
}

- (void)_setupFancyPantsContext {
    void (^logBlock)(NSString *log) = ^(id arg) { [self printString:[arg isKindOfClass:[JSValue class]] ? [[arg toObject] description] : [arg description]]; };

#if TARGET_OS_MAC
    self[@"_cwd"] = [NSFileManager defaultManager].currentDirectoryPath;
#endif

    self[@"objectDescription"] = ^(JSValue *val) { return [val.toObject description]; };
    __weak typeof(self) _self = self;
    self[@"require"] = _requireBlock = ^JSValue *(NSString *name) {

        BOOL isScript = [name hasSuffix:@".js"];
        if([name hasPrefix:@"./"] || !name.isAbsolutePath) {
            name = [_self.currentEvaluatingScriptPath stringByAppendingPathComponent:name];
        }
//        else {
//            _self.currentEvaluatingScriptPath = [name substringToIndex:(name.length - [name lastPathComponent].length)];
//        }



        if(isScript) {
            return [_self evaluateScriptAtPath:name];
        } else if([name hasSuffix:@".mkmodule"]
                   || [name hasSuffix:@".bundle"]
                   || [name hasSuffix:@".dylib"]) {
            return [_self loadNativeModuleAtPath:name];
        }

        return nil;
    };

    NSProcessInfo *info = [NSProcessInfo processInfo];
    self[@"process"] = @{
#if TARGET_OS_MAC
                         @"exit" : ^(int code) { exit(code); },
                         @"chdir" : ^(NSString *dir) { _self[@"_cwd"] = dir; },
                         @"cwd" : ^JSValue *{ return _self[@"_cwd"]; },
#endif
                         @"execPath" : [NSBundle mainBundle].executablePath,
                         @"pid" : @(info.processIdentifier),
                         @"moduleLoadList" : @[],
                         @"version" : [NSString stringWithFormat:@"%u.%u.%u", kMIDIKitVersionMajor, kMIDIKitVersionMinor, kMIDIKitVersionPatch]
                         };
    self[@"console"] = @{
                         @"log" : logBlock,
                         };
    if(info.environment) {
        self[@"process"][@"env"] = info.environment;
    }
    if(info.arguments) {
        self[@"process"][@"argv"] = info.arguments;
    }
    self[@"log"] = logBlock;

    MKInstallIntoContext(self);
}

- (JSValue *)evaluateScriptAtPath:(NSString *)name {
    BOOL isValidScript =
    [name hasSuffix:@".js"]
    && [[name lastPathComponent] componentsSeparatedByString:@"."].count > 1
    && [[NSFileManager defaultManager] fileExistsAtPath:name];

    __weak typeof(self) _self = self;
    switch ((UInt8)isValidScript) {
        case YES: {

            NSError *e;
            self[@"exports"] = self[@"module"] = @{ @"exports" : @{} };

            static NSString *evalFmt =
            @"(function () { "
                "var obj = (function () { "
                    "%@ "
                "})(); "
            "return module.exports; })()";
            NSString *eval = [NSString stringWithFormat:evalFmt, [NSString stringWithContentsOfFile:name encoding:NSUTF8StringEncoding error:&e]];

            if(e) {
                [_self printString:[NSString stringWithFormat:@"Error loading script: \'%@\'", name]];
                return nil;
            }
            JSValue *val = [_self evaluateScript:eval];

//            static NSString *clearModule = @"delete module";
//            [_self evaluateScript:clearModule];

            if(!val) {
                [_self printString:[NSString stringWithFormat:@"Error evaluating script: \'%@\', error = %@", name, e]];
            } else {
                [_self evaluateScript:[NSString stringWithFormat:@"process.moduleLoadList.push(\'ScriptModule %@\');", name.lastPathComponent]];
            }

            return val;
        } break;
        case NO: {

        } break;
    }

    return nil;
}

#if TARGET_OS_MAC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static JSValue *_MKJavaScriptContextRequireHook(Class self, SEL _cmd, MKJavaScriptContext *ctx) {
    return ctx[NSStringFromClass(self)];
}
#pragma clang diagnostic pop
#endif

- (JSValue *)loadNativeModuleAtPath:(NSString *)path {
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    // IPHONE CANNOT LOAD CODE
    [NSException raise:@"MKInvalidFeatureException" format:@"iOS cannot load code dynamically"];
    return nil;
#else

    BOOL isDir;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        return nil;
    }

    if(isDir) {
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(classesLoaded:) name:NSBundleDidLoadNotification object:bundle];
        if([bundle load]) {
            Class pClass= [bundle principalClass];
            if(![pClass respondsToSelector:@selector(requireReturnValue:)]) {
                class_addMethod(objc_getMetaClass(class_getName(pClass)), @selector(requireReturnValue:), (IMP)_MKJavaScriptContextRequireHook, [MKJavaScriptContext methodSignatureForSelector:@selector(requireReturnValue:)].methodReturnType);
            }

            JSValue *ret = [self loadNativeModule:pClass];
            return ret;
        }

        return nil; // this is async w/ notification
    }

    else {
        void *handle = dlopen(path.UTF8String, RTLD_NOW);
        if(!handle) return nil;

        Class (*MKModuleClass)() = dlsym(handle, "MKModuleClass");
        if(!MKModuleClass) return nil;

        return [self loadNativeModule:MKModuleClass()];
    }
#endif

    return nil;
}

- (void)loadClass:(Class)c {
    if([self classIsLoaded:c]) return;

    self[NSStringFromClass(c)] = c;
}

- (BOOL)classIsLoaded:(Class)c {
    NSString *key = NSStringFromClass(c);
    JSValue *val = self[key];

    return val && !val.isUndefined;
}

- (JSValue *)loadNativeModule:(Class<MKJavaScriptModule>)module withListName:(NSString *)listName {
    Class cMod = (Class)module;
    if([loadedModules containsObject:module]) return [module requireReturnValue:self];
    if(![cMod conformsToProtocol:@protocol(MKJavaScriptModule)]) return nil;

    if([cMod respondsToSelector:@selector(classesToLoad:)]) {
        for(Class cls in [module classesToLoad:self]) {
            [self loadClass:cls];
        }
    }
    [self loadClass:cMod];

    NSString *className = NSStringFromClass(cMod);
    static NSString *script = @"process.moduleLoadList.push(\'%@ %@\');";
    NSString *formatted = [NSString stringWithFormat:script, listName, className];
    [self evaluateScript:formatted];

    JSValue *ret = nil;
    if([cMod respondsToSelector:@selector(requireReturnValue:)]) {
        ret = [cMod requireReturnValue:self];
    }

    [loadedModules addObject:module];
    
    return ret;
}

- (JSValue *)loadNativeModule:(Class<MKJavaScriptModule>)module {
    return [self loadNativeModule:module withListName:@"NativeModule"];
}

- (void)setObject:(id)object forKeyedSubscript:(NSObject<NSCopying> *)key {
    [super setObject:object forKeyedSubscript:key];
}

- (JSValue *)objectForKeyedSubscript:(id)key {
    return [super objectForKeyedSubscript:key];
}

@end
