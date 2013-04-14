//
//  UIImageView+RRWebImage.m
//  RRSpring
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "UIImageView+RRWebImage.h"

@implementation UIImageView (RRWebImage)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    RRWebImageManager *manager = [RRWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    self.image = placeholder;
    
    if (url)
    {
        [manager downloadWithURL:url delegate:self];
    }
}

- (void)addTargetForTouch:(id)target action:(SEL)action
{
    UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]   
                                          initWithTarget:target action:action]autorelease];
    [self addGestureRecognizer:singleTap]; 
}

- (void)cancelCurrentImageLoad
{
    [[RRWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(RRWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    self.image = image;
}


@end
