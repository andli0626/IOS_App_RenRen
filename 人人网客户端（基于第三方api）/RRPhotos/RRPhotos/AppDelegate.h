//
//  AppDelegate.h
//  RRPhotos
//
//  Created by yi chen on 12-3-26.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
	//根,第一个界面是登陆界面,登陆后进入主界面
	UINavigationController *_rootNavController;
	
	//主界面
	UIViewController *_mainViewController;
}
@property (strong, nonatomic) UIWindow *window;
//最根的Controller
@property (nonatomic,retain) UINavigationController *rootNavController;
@property (nonatomic,retain) UIViewController *mainViewController;
@end
