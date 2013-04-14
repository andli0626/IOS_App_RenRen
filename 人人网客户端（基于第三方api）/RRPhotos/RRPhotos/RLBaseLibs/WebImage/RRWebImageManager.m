//
//  RRWebImageManager.m
//  RRSpring
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RRWebImageManager.h"
#import <objc/message.h>

static RRWebImageManager *instance;

@implementation RRWebImageManager

+ (id)sharedManager
{
    if (instance == nil)
    {
        instance = [[RRWebImageManager alloc] init];
    }
    
    return instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        _downloadDelegates = [[NSMutableArray alloc] init];
        _downloaders = [[NSMutableArray alloc] init];
        _cacheDelegates = [[NSMutableArray alloc] init];
        _cacheURLs = [[NSMutableArray alloc] init];
        _downloaderForURL = [[NSMutableDictionary alloc] init];
        _failedURLs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    RL_RELEASE_SAFELY(_downloadDelegates);
    RL_RELEASE_SAFELY(_downloaders);
    RL_RELEASE_SAFELY(_cacheDelegates);
    RL_RELEASE_SAFELY(_cacheURLs);
    RL_RELEASE_SAFELY(_downloaderForURL);
    RL_RELEASE_SAFELY(_failedURLs);
    [super dealloc];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<RRWebImageManagerDelegate>)delegate
{
    if ([url isKindOfClass:NSString.class])
    {
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    if (!url || !delegate || [_failedURLs containsObject:url])
    {
        return;
    }
    
    // Check the on-disk cache async so we don't block the main thread
    [_cacheDelegates addObject:delegate];
    [_cacheURLs addObject:url];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate", url, @"url", nil];
    [[RRWebImageCache sharedImageCache] queryDiskCacheForKey:[url absoluteString] delegate:self userInfo:info];
}

- (void)cancelForDelegate:(id<RRWebImageManagerDelegate>)delegate
{
    NSUInteger idx;
    while ((idx = [_cacheDelegates indexOfObjectIdenticalTo:delegate]) != NSNotFound)
    {
        [_cacheDelegates removeObjectAtIndex:idx];
        [_cacheURLs removeObjectAtIndex:idx];
    }
    
    while ((idx = [_downloadDelegates indexOfObjectIdenticalTo:delegate]) != NSNotFound)
    {
        RRWebImageDownloader *downloader = [[_downloaders objectAtIndex:idx] retain];
        
        [_downloadDelegates removeObjectAtIndex:idx];
        [_downloaders removeObjectAtIndex:idx];
        
        if (![_downloaders containsObject:downloader])
        {
            // No more delegate are waiting for this download, cancel it
            [downloader cancel];
            [_downloaderForURL removeObjectForKey:downloader.url];
        }
        
        [downloader release];
    }
}
#pragma mark SDImageCacheDelegate

- (NSUInteger)indexOfDelegate:(id<RRWebImageManagerDelegate>)delegate waitingForURL:(NSURL *)url
{
    // Do a linear search, simple (even if inefficient)
    NSUInteger idx;
    for (idx = 0; idx < [_cacheDelegates count]; idx++)
    {
        if ([_cacheDelegates objectAtIndex:idx] == delegate && [[_cacheURLs objectAtIndex:idx] isEqual:url])
        {
            return idx;
        }
    }
    return NSNotFound;
}

- (void)imageCache:(RRWebImageCache *)imageCache didFindImage:(UIImage *)image forKey:(NSString *)key userInfo:(NSDictionary *)info
{
    NSURL *url = [info objectForKey:@"url"];
    id<RRWebImageManagerDelegate> delegate = [info objectForKey:@"delegate"];
    
    NSUInteger idx = [self indexOfDelegate:delegate waitingForURL:url];
    if (idx == NSNotFound)
    {
        // Request has since been canceled
        return;
    }
    
    if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:)])
    {
        [delegate performSelector:@selector(webImageManager:didFinishWithImage:) withObject:self withObject:image];
    }
    if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:forURL:)])
    {
        objc_msgSend(delegate, @selector(webImageManager:didFinishWithImage:forURL:), self, image, url);
    }
   
    [_cacheDelegates removeObjectAtIndex:idx];
    [_cacheURLs removeObjectAtIndex:idx];
}

- (void)imageCache:(RRWebImageCache *)imageCache didNotFindImageForKey:(NSString *)key userInfo:(NSDictionary *)info
{
    NSURL *url = [info objectForKey:@"url"];
    id<RRWebImageManagerDelegate> delegate = [info objectForKey:@"delegate"];
    
    NSUInteger idx = [self indexOfDelegate:delegate waitingForURL:url];
    if (idx == NSNotFound)
    {
        // Request has since been canceled
        return;
    }
    
    [_cacheDelegates removeObjectAtIndex:idx];
    [_cacheURLs removeObjectAtIndex:idx];
    
    // Share the same downloader for identical URLs so we don't download the same URL several times
    RRWebImageDownloader *downloader = [_downloaderForURL objectForKey:url];
    
    if (!downloader)
    {
        downloader = [RRWebImageDownloader downloaderWithUrl:url userInfo:info delegate:self];
        //downloader.delegate = self;
        [_downloaderForURL setObject:downloader forKey:url];
    }
    else
    {
        // Reuse shared downloader
        downloader.userInfo = info;
    }
    
    [_downloadDelegates addObject:delegate];
    [_downloaders addObject:downloader];
}

#pragma mark SDWebImageDownloaderDelegate

- (void)imageDownloader:(RRWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image
{
    [downloader retain];

    // Notify all the downloadDelegates with this downloader
    for (NSInteger idx = (NSInteger)[_downloaders count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        RRWebImageDownloader *aDownloader = [_downloaders objectAtIndex:uidx];
        if (aDownloader == downloader)
        {
            id<RRWebImageManagerDelegate> delegate = [_downloadDelegates objectAtIndex:uidx];
            [delegate retain];
            [delegate autorelease];
            
            if (image)
            {
                if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:)])
                {
                    [delegate performSelector:@selector(webImageManager:didFinishWithImage:) withObject:self withObject:image];
                }
                if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:forURL:)])
                {
                    objc_msgSend(delegate, @selector(webImageManager:didFinishWithImage:forURL:), self, image, downloader.url);
                }
            }
            else
            {
                if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:)])
                {
                    [delegate performSelector:@selector(webImageManager:didFailWithError:) withObject:self withObject:nil];
                }
                if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:forURL:)])
                {
                    objc_msgSend(delegate, @selector(webImageManager:didFailWithError:forURL:), self, nil, downloader.url);
                }
            }
            
            [_downloaders removeObjectAtIndex:uidx];
            [_downloadDelegates removeObjectAtIndex:uidx];
        }
    }
    
    if(image)
    {
        // Store the image in the cache
        [[RRWebImageCache sharedImageCache] storeImage:image
                                          imageData:downloader.imageData
                                             forKey:[downloader.url absoluteString]
                                             toDisk:YES];
    }
    else
    {
        //[_failedURLs addObject:downloader.url];
    }
    
    // Release the downloader
    [_downloaderForURL removeObjectForKey:downloader.url];
    [downloader release];
}

- (void)imageDownloader:(RRWebImageDownloader *)downloader didFailWithError:(NSError *)error;
{
    [downloader retain];
    
    // Notify all the downloadDelegates with this downloader
    for (NSInteger idx = (NSInteger)[_downloaders count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        RRWebImageDownloader *aDownloader = [_downloaders objectAtIndex:uidx];
        if (aDownloader == downloader)
        {
            id<RRWebImageManagerDelegate> delegate = [_downloadDelegates objectAtIndex:uidx];
            [delegate retain];
            [delegate autorelease];
            
            if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:)])
            {
                [delegate performSelector:@selector(webImageManager:didFailWithError:) withObject:self withObject:error];
            }
            if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:forURL:)])
            {
                objc_msgSend(delegate, @selector(webImageManager:didFailWithError:forURL:), self, error, downloader.url);
            }
          
            [_downloaders removeObjectAtIndex:uidx];
            [_downloadDelegates removeObjectAtIndex:uidx];
        }
    }
    
    // Release the downloader
    [_downloaderForURL removeObjectForKey:downloader.url];
    [downloader release];
}

@end
