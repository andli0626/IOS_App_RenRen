//
//  AppDelegate.m
//  RRPhotos
//
//  Created by yi chen on 12-3-26.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "AppDelegate.h"
#import "RNLoginViewController.h"
//#import "RNLoginController.h"
#import "RNMainViewController.h"
#import "ImageProcessingViewController.h"
#import "RNConstomTabBarController.h"

//换掉背景图片 ios5以前
@implementation UINavigationBar (CustomImage)  
- (void)drawRect:(CGRect)rect { 
	UIImage *image = [UIImage imageNamed: @"button_bar.png"]; 
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

} 
@end 


@implementation AppDelegate

@synthesize window = _window;
@synthesize rootNavController = _rootNavController;
@synthesize mainViewController = _mainViewController;
- (void)dealloc
{
	[_window release];
	[_rootNavController release];
	[_mainViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//设置全部UINavigationBar图片背景
//	[[UINavigationBar appearance] setTintColor:[UIColor clearColor]];
	[[UINavigationBar appearance] setTintColor:RGBCOLOR(48, 48, 48)];

	if ([UINavigationBar instancesRespondToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
		
		[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"button_bar.png"] forBarMetrics:UIBarMetricsDefault];
	}

	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	
	//登陆界面
	RNLoginViewController *loginController = [[RNLoginViewController alloc]init];
	NSLog(@"loginController retain count = %d",[loginController retainCount]);
	UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:loginController];
	NSLog(@"2loginController retain count = %d",[loginController retainCount]);

	TT_RELEASE_SAFELY(loginController);
	self.rootNavController = navController;
	self.rootNavController.view.backgroundColor = [UIColor clearColor];
	NSLog(@"nav retain count = %d",[navController retainCount]);
	self.window.rootViewController = navController;
	[navController release];
	NSLog(@"nav retain count = %d",[navController retainCount]);
	
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (UIViewController *)mainViewController{
	if (!_mainViewController) {
		//主界面
		RNMainViewController *mainViewController = [[RNMainViewController alloc]init];
		_mainViewController = mainViewController;

	}
	return _mainViewController;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

@end