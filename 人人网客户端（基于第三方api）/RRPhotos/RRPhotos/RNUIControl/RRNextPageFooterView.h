//
//  EGONextPageFooterView.h
//  LetvIpadClient
//
//  Created by siglea on 12-04-05.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RNView.h"

typedef enum{
	EGOOPullNextPagePulling = 0,
	EGOOPullNextPageNormal,
	EGOOPullNextPageLoading,
	EGOOPullLastPage,
} EGOPullNextPageState;

@interface RRNextPageFooterView : RNView {
	
	UILabel *statusLabel;
	CALayer *arrowImage;
	UIView *arrowView;
	UIActivityIndicatorView *activityView;
	
	EGOPullNextPageState _state;
	BOOL isLastPage;
}

@property(nonatomic,assign) EGOPullNextPageState state;
@property (nonatomic) BOOL isLastPage;
- (void)setState:(EGOPullNextPageState)aState;

@end



