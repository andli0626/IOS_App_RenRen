//
//  RRWebImageDownloader.h
//  RRSpring
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RRWebImageDecoder.h"

@protocol RRWebImageDownloaderDelegate;

@interface RRWebImageDownloader : NSObject<RRWebImageDecoderDelegate>{
    NSURL* _url;
    id<RRWebImageDownloaderDelegate> _delegate;
    NSURLConnection* _connection;
    NSMutableData* _imageData;
    id _userInfo;
}
@property (nonatomic, retain)NSURL* url;
@property (nonatomic, assign)id<RRWebImageDownloaderDelegate> delegate;
@property (nonatomic, retain)NSMutableData* imageData;
@property (nonatomic, retain)id userInfo;

+ (id)downloaderWithUrl:(NSURL*)url userInfo:(id)userInfo delegate:(id<RRWebImageDownloaderDelegate>)delegate;
- (void)start;
- (void)cancel;

@end

@protocol RRWebImageDownloaderDelegate <NSObject>

@optional

- (void)imageDownloaderDidFinish:(RRWebImageDownloader *)downloader;
- (void)imageDownloader:(RRWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image;
- (void)imageDownloader:(RRWebImageDownloader *)downloader didFailWithError:(NSError *)error;

@end