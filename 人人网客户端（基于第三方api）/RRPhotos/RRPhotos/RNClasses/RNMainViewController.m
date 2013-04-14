//
//  RNMainViewController.m
//  RRPhotos
//
//  Created by yi chen on 12-4-7.
//  Copyright (c) 2012年 renren. All rights reserved.
//
#import "AppDelegate.h"
#import "RNMainViewController.h"
#import "RNNewsFeedController.h"
#import "RNRootNewsFeedController.h"
#import "ImageProcessingViewController.h"
#import "RNPickPhotoHelper.h"
#import "RNAlbumListViewController.h"
#import "RNHotShareViewController.h"
@interface RNMainViewController ()

//初始设置
- (void)initView;
@end

@implementation RNMainViewController
@synthesize tabBarController = _tabBarController;

@synthesize pickHelper = _pickHelper;
@synthesize newsFeedController = _newsFeedController;

@synthesize lastSelectIndex = _lastSelectIndex;

- (void)dealloc{
	self.tabBarController = nil;

	self.pickHelper = nil;
	self.newsFeedController = nil;

	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

		[self initView];
		NSLog(@"main retain count %d",[self retainCount]);
    }
    return self;
}


- (void)initView{
	
	//照片拾取器
	RNPickPhotoHelper *help = [[RNPickPhotoHelper alloc]init];
	self.pickHelper = help;
	TT_RELEASE_SAFELY(help);
}

- (void)loadView{
	[super loadView];
	
}

- (UITabBarController *)tabBarController{
	if (!_tabBarController) {
		NSArray *item = [[NSArray alloc]initWithObjects:@"动态", @"热门",@"拍照",@"多图",@"更多",nil];
		NSMutableArray *controllers = [NSMutableArray array];//视图控制器数组
		
		for (int i = 0 ; i < [item count]; i++) {
			
			UIViewController *mainView;
			UINavigationController *nav;
			
			switch (i) { //设置背景
				case 0:{
					
					mainView = [[RNNewsFeedController alloc]init];
					mainView.title = [item objectAtIndex: i];
					nav = [[UINavigationController alloc]initWithRootViewController:mainView];
					[mainView release];
					
					nav.tabBarItem.image = [UIImage imageNamed: @"main_p_model.png"];
					nav.navigationBar.barStyle = UIBarStyleDefault;
					[controllers addObject: nav];
					[nav release];
					
				}break;
					
				case 1:{
					
					mainView = [[RNHotShareViewController alloc]init];
					mainView.view.backgroundColor = [UIColor greenColor];
					mainView.title = [item objectAtIndex:i];
					nav = [[UINavigationController alloc]initWithRootViewController:mainView];
					
					TT_RELEASE_SAFELY(mainView);
					nav.tabBarItem.image = [UIImage imageNamed: @"publisher_status.png"];
					[controllers addObject: nav];
					TT_RELEASE_SAFELY(nav);
					
				}break;
					
				case 2:{
					mainView = [[UIViewController alloc]init];
					mainView.title = [item objectAtIndex:i];
					mainView.view.frame = CGRectZero;
					nav = [[UINavigationController alloc]initWithRootViewController:mainView];
					
					TT_RELEASE_SAFELY(mainView);
					
					nav.tabBarItem.image = [UIImage imageNamed: @"publisher_photo.png"];
					nav.view.frame = CGRectZero;
					[controllers addObject: nav];
					TT_RELEASE_SAFELY(nav);
					
				}break;
					
				case 3:{
					
					mainView = [[UIViewController alloc]init];
					mainView.title = [item objectAtIndex:i];
					mainView.view.frame = CGRectZero;
					nav = [[UINavigationController alloc]initWithRootViewController:mainView];
					
					TT_RELEASE_SAFELY(mainView);
					
					nav.tabBarItem.image = [UIImage imageNamed: @"navigation_extend_icon.png"];
					
					nav.view.frame = CGRectZero;
					[controllers addObject: nav];
					TT_RELEASE_SAFELY(nav);
					
				}break;
					
				case 4:{
					mainView = [[RNAlbumListViewController alloc]init];
					mainView.view.backgroundColor = [UIColor blueColor];
					mainView.title = [item objectAtIndex:i];
					nav = [[UINavigationController alloc]initWithRootViewController:mainView];
					TT_RELEASE_SAFELY(mainView);
					nav.tabBarItem.image =  [[RCResManager getInstance]imageForKey:@"main_btn_more"]; //[UIImage imageNamed:@"main_btn_more.png"];
					
					[controllers addObject: nav];
					TT_RELEASE_SAFELY(nav);
					
				}break;
					
				default:
					
					break;
			}
			
		}
		
		UITabBarController *tabBarController = [[UITabBarController alloc]init];
		tabBarController.viewControllers = controllers;//设置tabbar所对应的视图控制器
		tabBarController.delegate = self;
		tabBarController.view.frame = CGRectMake(0, 0, PHONE_SCREEN_SIZE.width, PHONE_SCREEN_SIZE.height);
		_tabBarController = tabBarController;

		NSLog(@"tabBarController %d",[_tabBarController retainCount]);

	}
	return _tabBarController;
}
- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
//	[[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	NSLog(@"retain count %d",[self retainCount]);
	[self.view addSubview: self.tabBarController.view];
	NSLog(@"retain count %d",[self retainCount]);
}

- (void)viewDidUnload
{
		
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	if (self.tabBarController.selectedIndex == 0) {
//		UIViewController *controller = self.tabBarController.selectedViewController;
//		if ([controller isKindOfClass:[UINavigationController class]])
//			controller = [(UINavigationController *)controller visibleViewController];
//		return [controller shouldAutorotateToInterfaceOrientation:interfaceOrientation];
//	}
//	return NO;
//}

/**
 *	取出当前活动的controller
 */
- (UIViewController *)activeViewController{
	UIViewController * activeViewController = [self.tabBarController selectedViewController];
	if (activeViewController) {
		return activeViewController;
	}
	return nil;
}

#pragma -mark UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController 
			didSelectViewController:(UIViewController *)viewController{
	
	if (viewController == [tabBarController.viewControllers objectAtIndex:2]) { //拍照功能
		[self.pickHelper pickPhotoWithSoureType:UIImagePickerControllerSourceTypeCamera];
		[tabBarController setSelectedViewController:[tabBarController.viewControllers objectAtIndex: _lastSelectIndex]];
	}else if (viewController == [tabBarController.viewControllers objectAtIndex:3]) { //选择照片功能
		[self.pickHelper pickPhotoWithSoureType:UIImagePickerControllerSourceTypePhotoLibrary];
		[tabBarController setSelectedViewController:[tabBarController.viewControllers objectAtIndex: _lastSelectIndex]];

	}else {
		_lastSelectIndex = [tabBarController selectedIndex];
		[tabBarController setSelectedViewController:[tabBarController.viewControllers objectAtIndex: _lastSelectIndex]];
	}
	
	[self viewWillAppear:YES];
}

#pragma -mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
	
}
@end
