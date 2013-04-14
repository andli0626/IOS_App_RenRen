//
//  RNFileCacheManager.h
//  RRSpring
//
//  Created by sheng siglea on 3/28/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNFileCacheManager : NSObject

/*
 应用document目录
 */
+(NSString *)appDocumentPath;
/*
 应用临时目录
 */
+(NSString *)appTmpPath;
/*
 应用缓存目录，设备可用容量不足，会清除该目录数据
 */
+(NSString *)appCachePath;
/**
 * 根据绝对路径删除文件
 * @param  filePath 绝对路径
 */
+(void)deleteFileWithPath:(NSString *)filePath;
/**
 * 获取绝对目录文件的大小 
 */
+(int)getFileSizeWithPath:(NSString *)filePath;

/**
 * 缓存文件
 * @param  fileName 文件名
 */
+(void)cacheFileWithData:(NSData *)data withFileName:(NSString *)fileName;
/**
 * 判断文件十分缓存
 * @param  fileName 文件名
 */
+(BOOL)isCachedFileWithFileName:(NSString *)fileName;
/**
 * 获取已缓存文件
 * @param  fileName 文件名
 */
+(NSData *)dataWithFileName:(NSString *)fileName;
/**
 * 文件的绝对缓存目录
 * @param  fileName 文件名
 */
+(NSString *)fileAbsoluteCachePath:(NSString *)fileName;
/**
 * 清空缓存
 */
+(void) clearCache;
@end
