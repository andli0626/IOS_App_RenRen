//
//  RRWebImageDownloader.m
//  RRSpring
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RRWebImageDownloader.h"

@interface RRWebImageDownloader()
@property (nonatomic, retain) NSURLConnection *connection;
@end


@implementation RRWebImageDownloader
@synthesize url = _url;
@synthesize delegate = _delegate;
@synthesize imageData = _imageData;
@synthesize userInfo = _userInfo;
@synthesize connection = _connection;

+ (id)downloaderWithUrl:(NSURL*)url userInfo:(id)userInfo delegate:(id<RRWebImageDownloaderDelegate>)delegate
{
    RRWebImageDownloader* downloader = [[[RRWebImageDownloader alloc] init] autorelease];
    downloader.url = url;
    downloader.userInfo = userInfo;
    downloader.delegate = delegate;
    [downloader performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    return downloader;
}

- (void)start
{
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO] autorelease];
    [self.connection start];
    RL_RELEASE_SAFELY(request);
    
    if(self.connection){
        NSLog(@"RRWebImageDownLoader success");
        self.imageData = [NSMutableData data];
#warning 打印照片数据注释掉
//        NSLog(@"self.imageData = %@",self.imageData);
        
    }
    else {
        if([self.delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)]){
            [self.delegate performSelector:@selector(imageDownloader:didFailWithError:) withObject:self withObject:nil];
//            NSLog(@"RRWebImageDownLoader fail");
        }
    }
}

- (void)cancel
{
    if(self.connection){
        [self.connection cancel];
        self.connection = nil;
    }
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response
{
    if ([((NSHTTPURLResponse *)response) statusCode] >= 400)
    {
        [aConnection cancel];
        
        if ([self.delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)])
        {
            NSError *error = [[[NSError alloc] initWithDomain:NSURLErrorDomain
                                                        code:[((NSHTTPURLResponse *)response) statusCode]
                                                    userInfo:nil] autorelease];
            [self.delegate performSelector:@selector(imageDownloader:didFailWithError:) withObject:self withObject:error];
        }
        
        self.connection = nil;
        self.imageData = nil;
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
//    NSLog(@"connection self.imageData = %@",self.imageData);
}

#pragma mark NSURLConnectionDataDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    self.connection = nil;

    if ([self.delegate respondsToSelector:@selector(imageDownloaderDidFinish:)])
    {
        [self.delegate performSelector:@selector(imageDownloaderDidFinish:) withObject:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(imageDownloader:didFinishWithImage:)])
    {
        UIImage *image = RRScaledImageForPath(self.url.absoluteString, self.imageData);
        [[RRWebImageDecoder sharedImageDecoder] decodeImage:image withDelegate:self userInfo:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{ 
    if ([self.delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)])
    {
        [self.delegate performSelector:@selector(imageDownloader:didFailWithError:) withObject:self withObject:error];
    }
    
    self.connection = nil;
    self.imageData = nil;
}

#pragma mark SDWebImageDecoderDelegate

- (void)imageDecoder:(RRWebImageDecoder *)decoder didFinishDecodingImage:(UIImage *)image userInfo:(NSDictionary *)userInfo
{
    [self.delegate performSelector:@selector(imageDownloader:didFinishWithImage:) withObject:self withObject:image];
}

#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    RL_RELEASE_SAFELY(_url);
    RL_RELEASE_SAFELY(_connection);
    RL_RELEASE_SAFELY(_imageData);
    RL_RELEASE_SAFELY(_userInfo);
    [super dealloc];
}

@end
