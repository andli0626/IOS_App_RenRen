//
//  RNRootNewsFeedController.h
//  RRPhotos
//
//  Created by yi chen on 12-5-13.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNHotShareViewController.h"
#import "RNNewsFeedController.h"
@interface RNRootNewsFeedController : UIViewController
{
	//好友动态
	RNNewsFeedController *_newsFeedController;
	//热门分享
	RNHotShareViewController *_hotShareController;
	
	@private
	//指示当前显示的是好友动态还是热门分享
	UIViewController *_currentViewController;
}
@property(nonatomic,retain)RNNewsFeedController *newsFeedController;
@property(nonatomic,retain)RNHotShareViewController *hotShareController;

@end
