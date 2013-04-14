//
//  Logger.m
//  xiaonei
//
//  Created by citydeer on 09-4-14.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RRLogger.h"


@implementation RRLogger

+ (void) file:(const char*)sourceFile function:(const char*)functionName lineNumber:(int)lineNumber format:(NSString*)format, ...
{
//#if 0
#if DEBUG_MODE
    if (!format) {
        return;
    }
	//*
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	va_list ap;
	NSString *print, *file, *function;
	
	va_start(ap,format);
	
	file = [[NSString alloc] initWithBytes:sourceFile length: strlen(sourceFile) encoding:NSUTF8StringEncoding];
	
	function = [NSString stringWithCString:functionName encoding:NSUTF8StringEncoding];
	
	print = [[NSString alloc] initWithFormat:format arguments:ap];
	
	va_end(ap);
	
	NSLog(@"%@:%d %@;\n%@\n\n", [file lastPathComponent], lineNumber, function, print);
	
	[print release];
	
	[file release];
	
	[pool release];	
	//*/
#endif
}

@end
