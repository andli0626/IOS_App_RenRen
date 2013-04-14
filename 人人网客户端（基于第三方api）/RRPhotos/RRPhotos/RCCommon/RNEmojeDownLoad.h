//
//  RNEmojeDownLoad.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-11.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
 @protocol RNEmotionDownloadDelegate;
@interface RNEmojeDownLoad : NSObject
{    
    __unsafe_unretained id<RNEmotionDownloadDelegate> delegate;      
    BOOL       overwrite;                        
    NSURL      *url;
    NSString   *fileName;
    NSString   *filePath;
    unsigned long long fileSize;
    
@private
    NSString   *destinationPath;
    NSString   *temporaryPath;
    NSFileHandle        *fileHandle;
    NSURLConnection     *connection;
    unsigned long long  offset;
}

@property (nonatomic, assign) id<RNEmotionDownloadDelegate> delegate;
/*
 当文件名相同时是否覆盖,overwriter为NO的时候，当文件已经存在，则下载结束
 */
@property (nonatomic, assign) BOOL overwrite;
/*
 下载的地址,当下载地址为nil，下载失败
 */
@property (nonatomic, strong) NSURL *url;
/*
 下载文件的名字名，默认为下载原文件名
 */
@property (nonatomic, strong) NSString *fileName;
/*
 文件保存的path(不包括文件名),默认路径为DocumentDirectory
 */
@property (nonatomic, strong) NSString *filePath;
/*
 下载的大小,只有当下载任务成功启动之后才能获取
 */
@property (nonatomic, readonly) unsigned long long fileSize;

- (void)start;              //开始下载
- (void)stop;               //停止下载
- (void)stopAndClear;       //停止清理(己下载完成的或缓存)
-(void)cancel;
@end

@protocol RNEmotionDownloadDelegate<NSObject>
@optional
//下载开始(responseHeaders为服务器返回的下载文件的信息)
- (void)downloadBegin:(RNEmojeDownLoad *)aDownload didReceiveResponseHeaders:(NSURLResponse *)responseHeaders;
//下载失败
- (void)downloadFaild:(RNEmojeDownLoad *)aDownload didFailWithError:(NSError *)error;
//下载结束
- (void)downloadFinished:(RNEmojeDownLoad *)aDownload;
//更新下载的进度
- (void)downloadProgressChange:(RNEmojeDownLoad *)aDownload progress:(double)newProgress;


@end
