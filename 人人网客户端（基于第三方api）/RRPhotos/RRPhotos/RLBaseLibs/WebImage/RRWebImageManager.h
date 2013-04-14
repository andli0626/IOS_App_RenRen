//
//  RRWebImageManager.h
//  RRSpring
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RRWebImageDecoder.h"
#import "RRWebImageDownloader.h"
#import "RRWebImageCache.h"

@protocol RRWebImageManagerDelegate;

@interface RRWebImageManager : NSObject<RRWebImageDownloaderDelegate, RRWebImageCacheDelegate>{
    NSMutableArray* _downloadDelegates;
    NSMutableArray* _downloaders;
    NSMutableArray* _cacheDelegates;
    NSMutableArray* _cacheURLs;
    NSMutableDictionary* _downloaderForURL;
    NSMutableArray* _failedURLs;
}

+ (id)sharedManager;
- (void)downloadWithURL:(NSURL *)url delegate:(id<RRWebImageManagerDelegate>)delegate;
- (void)cancelForDelegate:(id<RRWebImageManagerDelegate>)delegate;

@end

@protocol RRWebImageManagerDelegate <NSObject>

@optional

- (void)webImageManager:(RRWebImageManager *)imageManager didFinishWithImage:(UIImage *)image;
- (void)webImageManager:(RRWebImageManager *)imageManager didFinishWithImage:(UIImage *)image forURL:(NSURL *)url;
- (void)webImageManager:(RRWebImageManager *)imageManager didFailWithError:(NSError *)error;
- (void)webImageManager:(RRWebImageManager *)imageManager didFailWithError:(NSError *)error forURL:(NSURL *)url;

@end
