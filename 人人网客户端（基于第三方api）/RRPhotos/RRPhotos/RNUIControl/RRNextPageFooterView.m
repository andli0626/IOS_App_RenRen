//
//  EGONextPageFooterView.m
//  LetvIpadClient
//
//  Created by siglea on 12-04-05.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RRNextPageFooterView.h"



#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define BORDER_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
@implementation RRNextPageFooterView

@synthesize state=_state;
@synthesize isLastPage;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		isLastPage = NO;
		statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, frame.size.width, 40)];
		statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		statusLabel.font = [UIFont boldSystemFontOfSize:14.0f];
		statusLabel.textColor = [UIColor darkGrayColor];
		statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.textAlignment = UITextAlignmentCenter;
		[self setState:EGOOPullNextPageNormal];
		[self addSubview:statusLabel];
		[statusLabel release];

		arrowImage = [[CALayer alloc] init];
		arrowImage.frame = CGRectMake(0, 0, 30, 55);
		arrowImage.contentsGravity = kCAGravityResizeAspect;
		arrowImage.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
		[arrowImage release];
		
		arrowView = [[UIView alloc] initWithFrame:CGRectMake(80, 5, 30, 55)];
		[[arrowView layer] addSublayer:arrowImage];
		[self addSubview:arrowView];
		[arrowView release];
		
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityView.frame = CGRectMake(75, 10, 20, 20);
		activityView.hidesWhenStopped = YES;
		[self addSubview:activityView];
		[activityView release];
		
    }
    return self;
}
- (void)drawRect:(CGRect)rect{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawPath(context,  kCGPathFillStroke);
	[[UIColor colorWithPatternImage:[UIImage imageNamed:@"default_playline.png"]] setStroke];
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, 1);
	CGContextAddLineToPoint(context, self.bounds.size.width, 1);
	CGContextStrokePath(context);
}


- (void)setState:(EGOPullNextPageState)aState{	
	switch (aState) {
		case EGOOPullNextPagePulling:
			if (_state == EGOOPullNextPagePulling
				||_state == EGOOPullNextPageLoading) {
				return;
			}
			statusLabel.text = NSLocalizedString(@"松开即可翻页...", @"");
			[CATransaction begin];
			[CATransaction setAnimationDuration:.18];
			arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			break;
		case EGOOPullNextPageNormal:
			if (_state == EGOOPullNextPageNormal) {
				return;
			}
			[CATransaction begin];
			[CATransaction setAnimationDuration:.18];
			arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			statusLabel.text = NSLocalizedString(@"上拉可以翻页...", @"");
			[activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			arrowImage.hidden = NO;
			arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			break;
		case EGOOPullNextPageLoading:
			if (_state == EGOOPullNextPageLoading
				||_state == EGOOPullNextPageNormal) {
				return;
			}
			statusLabel.text = NSLocalizedString(@"加载中...", @"");
			[activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		case EGOOPullLastPage:
			statusLabel.text = NSLocalizedString(@"已到末尾...", @"");
			[activityView stopAnimating];
			arrowImage.hidden = YES;
			
			break;
		default:
			break;
	}
	_state = aState;
}

- (void)dealloc {
	activityView = nil;
	statusLabel = nil;
	arrowImage = nil;
    [super dealloc];
}

@end