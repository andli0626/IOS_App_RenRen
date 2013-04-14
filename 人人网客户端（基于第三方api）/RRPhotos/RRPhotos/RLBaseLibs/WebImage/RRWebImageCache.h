//
//  RRWebImageCache.h
//  RRSpring
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RRWebImageCacheDelegate;

@interface RRWebImageCache : NSObject{
    NSMutableDictionary *_memCache;
    NSString *_diskCachePath;
    NSOperationQueue *_cacheInQueue, *_cacheOutQueue;
}

+ (RRWebImageCache *)sharedImageCache;
- (void)storeImage:(UIImage *)image forKey:(NSString *)key;
- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk;
- (void)storeImage:(UIImage *)image imageData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk;
- (UIImage *)imageFromKey:(NSString *)key;
- (UIImage *)imageFromKey:(NSString *)key fromDisk:(BOOL)fromDisk;
- (void)queryDiskCacheForKey:(NSString *)key delegate:(id <RRWebImageCacheDelegate>)delegate userInfo:(NSDictionary *)info;

- (void)removeImageForKey:(NSString *)key;
- (void)clearMemory;
- (void)clearDisk;
- (void)cleanDisk;
- (int)getSize;
@end

@protocol RRWebImageCacheDelegate <NSObject>

@optional
- (void)imageCache:(RRWebImageCache *)imageCache didFindImage:(UIImage *)image forKey:(NSString *)key userInfo:(NSDictionary *)info;
- (void)imageCache:(RRWebImageCache *)imageCache didNotFindImageForKey:(NSString *)key userInfo:(NSDictionary *)info;

@end
