//
//  RNScrollImageView.h
//  RRSpring
//
//  Created by sheng siglea on 3/21/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//


#import <UIKit/UIKit.h>
#define kTouchSpaceTimeInterval 0.174201
@protocol RNScrollImageViewDelegate;

@interface RNScrollImageView : UIScrollView <UIScrollViewDelegate>
{
	UIImageView *imageView;
    UIImage *_image;
    id<RNScrollImageViewDelegate> _RNScrollImageViewDelegate;
    NSTimer *_timer;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, assign) id<RNScrollImageViewDelegate> RNScrollImageViewDelegate;

- (void)adjustViews;
- (void)resetDefaultStatus;

@end

@protocol RNScrollImageViewDelegate

- (void)touchOneCountBegin:(RNScrollImageView  *)scrollImageView;
@end