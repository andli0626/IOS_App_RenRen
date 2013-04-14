//
//  Logger.h
//  xiaonei
//
//  Created by citydeer on 09-4-14.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RRLogger : NSObject 

+ (void) file:(const char*)sourceFile function:(const char*)functionName lineNumber:(int)lineNumber format:(NSString*)format, ...;

//#ifndef _XN_LOG_
//#define _XN_LOG_ 1

#define RRLOG_fatal(s,...) [RRLogger file:(char*)__FILE__ function:(char*)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define RRLOG_error(s,...) [RRLogger file:(char*)__FILE__ function:(char*)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define RRLOG_warn(s,...) [RRLogger file:(char*)__FILE__ function:(char*)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define RRLOG_info(s,...) [RRLogger file:(char*)__FILE__ function:(char*)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define RRLOG_debug(s,...) [RRLogger file:(char*)__FILE__ function:(char*)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]

//#endif

@end
