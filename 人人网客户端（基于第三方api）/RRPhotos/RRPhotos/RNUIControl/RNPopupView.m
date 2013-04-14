//
//  RNPopupView.m
//  RRSpring
//
//  Created by gaosi on 12-3-31.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPopupView.h"

@interface RNPopupView ()
@property (nonatomic, retain, readwrite)	id	targetObject;
@end


@implementation RNPopupView

@synthesize delegate = _delegate;
@synthesize targetObject = _targetObject;
@synthesize animation = _animation;
@synthesize backgroundView = _backgroundView;

- (void)presentPointingAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated {
	if (!self.targetObject) {
		self.targetObject = targetView;
	}
	
	[containerView addSubview:self];
	
	CGPoint targetRelativeOrigin    = [targetView.superview convertPoint:targetView.frame.origin toView:containerView.superview];
	CGPoint containerRelativeOrigin = [containerView.superview convertPoint:containerView.frame.origin toView:containerView.superview];
    
	CGFloat pointerY;	// Y coordinate of pointer target (within containerView)
	
	if (targetRelativeOrigin.y+targetView.bounds.size.height < containerRelativeOrigin.y) {
		pointerY = 0.0;
		_pointDirection = RNPointDirectionUp;
	}
	else if (targetRelativeOrigin.y > containerRelativeOrigin.y+containerView.bounds.size.height) {
		pointerY = containerView.bounds.size.height;
		_pointDirection = RNPointDirectionDown;
	}
	else {
		CGPoint targetOriginInContainer = [targetView convertPoint:CGPointMake(0.0, 0.0) toView:containerView];
		CGFloat sizeBelow = containerView.bounds.size.height - targetOriginInContainer.y-targetView.frame.size.height;
		if (sizeBelow > self.frame.size.height) {
			pointerY = targetOriginInContainer.y + targetView.bounds.size.height;
			_pointDirection = RNPointDirectionUp;
		}
		else {
			pointerY = targetOriginInContainer.y;
			_pointDirection = RNPointDirectionDown;
		}
	}
	
    CGSize bubbleSize = self.frame.size;
	CGFloat containerWidth = containerView.frame.size.width;
	
	CGFloat x_p = targetView.center.x;
	CGFloat x_b = x_p - roundf(bubbleSize.width/2);
	if (x_b < 0) {
		x_b = 0;
	}
	if (x_b + bubbleSize.width> containerWidth) {
		x_b = containerWidth - bubbleSize.width;
	}
	if (x_p - _pointerSize < x_b) {
		x_p = x_b + _pointerSize;
	}
	if (x_p + _pointerSize > x_b + bubbleSize.width) {
		x_p = x_b + bubbleSize.width - _pointerSize;
	}
	
	CGFloat fullHeight = bubbleSize.height + _pointerSize;
	CGFloat y_b;
	if (_pointDirection == RNPointDirectionUp) {
		y_b = 0 + pointerY;
		_targetPoint = CGPointMake(x_p-x_b, 0);
        [self.delegate popupViewDirectionChanged:RNPointDirectionUp];
	}
	else {
		y_b = pointerY - fullHeight;
		_targetPoint = CGPointMake(x_p-x_b, fullHeight-2.0);
        [self.delegate popupViewDirectionChanged:RNPointDirectionDown];
	}
	
	CGRect finalFrame = CGRectMake(x_b,y_b,bubbleSize.width,fullHeight);
	if (animated) {
        if (_animation == RNPopupAnimationSlide) {
            self.alpha = 0.0;
            CGRect startFrame = finalFrame;
            startFrame.origin.y += 10;
            self.frame = startFrame;
        }
		else if (_animation == RNPopupAnimationPop) {
            self.frame = finalFrame;
            self.alpha = 0.5;
            
            // start a little smaller
            self.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
            
            // animate to a bigger size
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(popAnimationDidStop:finished:context:)];
            [UIView setAnimationDuration:0.15f];
            self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
            self.alpha = 1.0;
            [UIView commitAnimations];
        }
		
		[self setNeedsDisplay];
		
		if (_animation == RNPopupAnimationSlide) {
			[UIView beginAnimations:nil context:nil];
			self.alpha = 1.0;
			self.frame = finalFrame;
			[UIView commitAnimations];
		}
	}
	else {
		// Not animated
		[self setNeedsDisplay];
		self.frame = finalFrame;
	}
}

- (void)finaliseDismiss {
	[self removeFromSuperview];
	self.targetObject = nil;
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self finaliseDismiss];
}

- (void)dismissAnimated:(BOOL)animated {
	if (animated) {
		CGRect frame = self.frame;
		frame.origin.y += 10.0;
		
		[UIView beginAnimations:nil context:nil];
		self.alpha = 0.0;
		self.frame = frame;
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
	else {
		[self finaliseDismiss];
	}
}

- (void)popAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // at the end set to normal size
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.opaque = NO;
		_pointerSize = 5.0;
		self.backgroundColor = [UIColor grayColor];
        self.animation = RNPopupAnimationSlide;
    }
    return self;
}

- (void)setBackgroundView:(UIImageView *)view
{
    if(_backgroundView == view) return;
    if(_backgroundView){
        [_backgroundView removeFromSuperview];
        //[_backgroundView release];
        _backgroundView = nil;
    }
    if(view){
        _backgroundView = [view retain];
        _backgroundView.frame = self.frame;
        self.backgroundColor = [UIColor clearColor];
        [self insertSubview:_backgroundView atIndex:0];
    }
}

- (void)dealloc {
    RL_RELEASE_SAFELY(_targetObject);
    RL_RELEASE_SAFELY(_backgroundView);
	
    [super dealloc];
}

@end
