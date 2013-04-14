//
//  UIImageView+RRWebImage.h
//  RRSpring
//
//  Created by  on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRWebImageManager.h"

@interface UIImageView (RRWebImage)<RRWebImageManagerDelegate>

/**
 * Set the imageView `image` with an `url`.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url for the image.
 */
- (void)setImageWithURL:(NSURL *)url;

/**
 * Set the imageView `image` with an `url` and a placeholder.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @see setImageWithURL:placeholderImage:options:
 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

// 增加触摸事件
- (void)addTargetForTouch:(id)target action:(SEL)action;

/**
 * Cancel the current download
 */
- (void)cancelCurrentImageLoad;

@end
