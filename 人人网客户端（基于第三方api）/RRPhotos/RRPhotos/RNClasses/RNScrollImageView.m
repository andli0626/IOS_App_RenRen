//
//  RNScrollImageView.m
//  RRSpring
//
//  Created by sheng siglea on 3/21/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNScrollImageView.h"
#define kBgColor [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1]

@interface RNScrollImageView (Private)

- (void)adjustSubviews;
- (void)disImageViewWithUrl:(NSString *)urlString;

@end

@implementation RNScrollImageView

@synthesize image = _image;
@synthesize RNScrollImageViewDelegate = _RNScrollImageViewDelegate;
@synthesize timer = _timer;

#pragma mark -
#pragma mark === Intilization ===
#pragma mark -
- (id)init
{
    if ((self = [super init]))
	{
		self.delegate = self;
		self.minimumZoomScale = 0.5;
		self.maximumZoomScale = 2.5;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:imageView];
    }
    return self;
}
- (void)adjustViews{
    if (imageView.image) {
        CGFloat height = (self.width * imageView.image.size.height)/imageView.image.size.width;
        imageView.size = CGSizeMake(self.width, height);
    }else {
        imageView.size = self.size;
    }
    self.contentSize = imageView.frame.size;
    [self adjustSubviews];
}
- (void)setImage:(UIImage *)img
{
    self.backgroundColor = [UIColor clearColor];
    if ([self viewWithTag:444]) {
        [[self viewWithTag:444] removeFromSuperview];
    }
	imageView.image = img;
    [self adjustViews];
}
- (void)resetDefaultStatus{
    imageView.image = nil;
    self.backgroundColor = kBgColor;
    self.contentSize = self.frame.size;
    UIImageView *defaultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 105, 105)];
    defaultImageView.tag = 444;
    defaultImageView.center = CGPointMake(self.width/2, self.height/2);
    defaultImageView.image = [[RCResManager getInstance] imageForKey:@"photo_load_default"];
    [self addSubview:defaultImageView];
    [defaultImageView release];
}
- (void)adjustSubviews{
    if (self.contentSize.height <= self.frame.size.height ||
        self.contentSize.width <= self.frame.size.width) {
        if (self.contentSize.height < self.frame.size.height) {
            self.contentSize = CGSizeMake(self.contentSize.width, self.frame.size.height);
        }
        if (self.contentSize.width < self.frame.size.width) {
            self.contentSize = CGSizeMake(self.frame.size.width, self.contentSize.height);
        }
        imageView.center = CGPointMake(self.contentSize.width/2, self.contentSize.height/2);
    }else {
        imageView.origin = CGPointZero;
    }
}
#pragma mark -
#pragma mark === UIScrollView Delegate ===
#pragma mark -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{	
    [self adjustSubviews];
	return imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self adjustSubviews];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{		
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];		
	scrollView.zoomScale = scale;	
    [self adjustSubviews];
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark === UITouch Delegate ===
#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 400毫秒左右没有收到第二次点击
	UITouch *touch = [touches anyObject];
//    NSLog(@".......%d",[touch tapCount]);
	if ([touch tapCount] == 2) 
	{
        if (self.timer && [self.timer isValid]) {
            [self.timer invalidate];
        }
		CGFloat zs = self.zoomScale;
		if (zs >= self.maximumZoomScale) {
            zs = self.minimumZoomScale;
        }
        zs = zs + .5;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];			
		self.zoomScale = zs;	
		[UIView commitAnimations];
	}else if([touch tapCount] == 1){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kTouchSpaceTimeInterval
                                                  target:self 
                                                selector:@selector(touchOneCountBegin) 
                                                userInfo:nil
                                                 repeats:NO];
    }
}
- (void)touchOneCountBegin{
//    RN_DEBUG_LOG;
    if (self.RNScrollImageViewDelegate) {
        [self.RNScrollImageViewDelegate touchOneCountBegin:self];
    }          
}
#pragma mark -
#pragma mark === dealloc ===
#pragma mark -
- (void)dealloc
{
    self.timer = nil;
	[imageView release];
    [super dealloc];
}
@end
