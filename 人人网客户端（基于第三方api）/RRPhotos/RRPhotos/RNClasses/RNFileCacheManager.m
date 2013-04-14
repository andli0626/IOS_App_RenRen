//
//  RNFileCacheManager.m
//  RRSpring
//
//  Created by sheng siglea on 3/28/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNFileCacheManager.h"

@implementation RNFileCacheManager
+(NSString *)appDocumentPath{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, 
                                                         YES);
	return [paths objectAtIndex:0];	
}
+(NSString *)appTmpPath{
	NSString *tempPath = NSTemporaryDirectory();
	return tempPath;
}
+(NSString *)appCachePath{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                NSUserDomainMask, 
                                                YES)	
            objectAtIndex: 0];
}

+(void)deleteFileWithPath:(NSString *)filePath{	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:filePath]) {
		[fileManager removeItemAtPath:filePath error:nil];
	}
}
+(int)getFileSizeWithPath:(NSString *)filePath{
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	if (![fileMgr fileExistsAtPath:filePath]) {
		return 0;
	}
	NSError *error = nil;
	NSDictionary *fileDict = [fileMgr attributesOfItemAtPath:filePath error:&error];
	return [[fileDict objectForKey:@"NSFileSize"] intValue];
}
+(NSString *)fileAbsoluteCachePath:(NSString *)fileName{
    return [[self appCachePath] stringByAppendingPathComponent: [fileName md5]];
}
+(void)cacheFileWithData:(NSData *)data withFileName:(NSString *)fileName{
    [data writeToFile: [self fileAbsoluteCachePath:fileName] atomically: YES];
}
+(BOOL)isCachedFileWithFileName:(NSString *)fileName{
    //FIXME 放到dictionary 快速检索
    return [[NSFileManager defaultManager] fileExistsAtPath: [self fileAbsoluteCachePath:fileName]];
}
+(NSData *)dataWithFileName:(NSString *)fileName{
    return [NSData dataWithContentsOfFile:[self fileAbsoluteCachePath:fileName]];
}

+(void) clearCache
{
	NSFileManager* fm = [NSFileManager defaultManager];
	NSError* err = nil;
	BOOL res;
	NSArray *array = [fm contentsOfDirectoryAtPath:[self appCachePath] error:nil];
	for(NSString *path in array){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		res = [fm removeItemAtPath:[[self appCachePath] stringByAppendingPathComponent:path] error:&err];
        if (!res && err) 
        {
            NSLog(@"oops: %@", err);
        }
		[pool release];
	}	
}
@end
