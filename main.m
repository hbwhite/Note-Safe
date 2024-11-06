//
//  main.m
//  Note Safe
//
//  Created by Harrison White on 7/15/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// Application Strings
// #import "ApplicationStrings.h"

// Debugger
// #import <sys/types.h>

// Removed for Compatibility Reasons
/*
// Encryption
#import <mach-o/dyld.h>
#import <TargetConditionals.h>
*/

// Debugger and Encryption
// #import <dlfcn.h>

// static BOOL saveDefaults();
// static BOOL readDefaults();

int main(int argc, char *argv[]) {
	/*
	didSaveDefaults = saveDefaults();
	didReadDefaults = readDefaults();
	*/
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}

/*
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

static BOOL saveDefaults() {
#if TARGET_IPHONE_SIMULATOR || defined(DEBUG) || (!defined(NS_BLOCK_ASSERTIONS) && !defined(NDEBUG))
	return YES;
#endif
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSMutableString *defaults = [[NSMutableString alloc]init];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(41, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(6, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(17, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(40, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(3, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	char socket[([defaults length] + 1)];
	strncpy(socket, [defaults UTF8String], ([defaults length] + 1));
	NSString *defaultsCopy = [NSString stringWithString:defaults];
	[defaults release];
	void *handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
	ptrace_ptr_t ptrace_ptr = dlsym(handle, socket);
	ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
	dlclose(handle);
	[pool release];
	return [defaultsCopy isEqualToString:@"ptrace"];
}

static BOOL readDefaults() {
#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO)
#define LC_ENCRYPTION_INFO 0x21
	struct encryption_info_command {
		uint32_t cmd;
		uint32_t cmdsize;
		uint32_t cryptoff;
		uint32_t cryptsize;
		uint32_t cryptid;
	};
#endif
	const struct mach_header *header;
	Dl_info dlinfo;
	if ((dladdr(main, &dlinfo) == 0) || (dlinfo.dli_fbase == NULL)) {
		// Could not find main() symbol, so most likely pirated.
		return NO;
	}
	header = dlinfo.dli_fbase;
	struct load_command *cmd = (struct load_command *)(header + 1);
	for (uint32_t i = 0; ((cmd != NULL) && (i < header->ncmds)); i++) {
		if (cmd->cmd == LC_ENCRYPTION_INFO) {
			struct encryption_info_command *crypt_cmd = (struct encryption_info_command *) cmd;
			if (crypt_cmd->cryptid < 1) {
				// Probably Pirated
				return NO;
			}
			// Probably Not Pirated
			return YES;
		}
		cmd = (struct load_command *)((uint8_t *) cmd + cmd->cmdsize);
	}
	// Encryption Information Not Found
	return NO;
}
*/
