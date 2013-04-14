//
//  RNMainViewController.h
//  RRPhotos
//
//  Created by yi chen on 12-4-7.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNPickPhotoHelper.h"
#import "RNNewsFeedController.h"
@interface RNMainViewController : UIViewController<UITabBarDelegate,UITabBarControllerDelegate>
{
	UITabBarController *_tabBarController;
	
	//照片拾取器
	RNPickPhotoHelper *_pickHelper;
	
	//新鲜事界面
	RNNewsFeedController *_newsFeedController;
	
	//记录上次选中的TabBarItem
	NSInteger _lastSelectIndex;
	
}
@property(nonatomic,retain)UITabBarController *tabBarController;

@property(nonatomic,retain)RNPickPhotoHelper *pickHelper;

@property(nonatomic,retain)RNNewsFeedController *newsFeedController;

@property(nonatomic,assign)NSInteger lastSelectIndex;

/**
 *	取出当前活动的controller
 */
- (UIViewController *)activeViewController;
@end
