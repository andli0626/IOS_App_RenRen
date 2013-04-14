//
//  RNRootNewsFeedController.m
//  RRPhotos
//
//  Created by yi chen on 12-5-13.
//  Copyright (c) 2012年 renren. All rights reserved.
//
#import <objc/runtime.h>
#import "RNRootNewsFeedController.h"
#import "AppDelegate.h"
@interface RNRootNewsFeedController ()

@end

@implementation RNRootNewsFeedController
@synthesize newsFeedController = _newsFeedController;
@synthesize hotShareController = _hotShareController;
- (void)dealloc{
	
	self.hotShareController = nil;
	self.newsFeedController = nil;
	[super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - view life
- (void)loadView{
	[super loadView];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.userInteractionEnabled = YES;
	
	//刷新按钮
	UIButton *refreshButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	UIImage *refreshButtonImage = [[RCResManager getInstance]imageForKey:@"webbrowser_refresh"];
	[refreshButton setImage:refreshButtonImage forState:UIControlStateNormal];
	[refreshButton setImage:refreshButtonImage forState:UIControlStateSelected];
	[refreshButton addTarget:self action:@selector(onClickRefreshButton) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:refreshButton];
	[refreshButton release];

	self.navigationItem.rightBarButtonItem = item;
	
	//中间栏
	UISegmentedControl *segmentControl = [[UISegmentedControl alloc]initWithItems:
										  [NSArray arrayWithObjects:@"好友动态",@"热门分享",nil]];
	CGFloat width = 150;
	segmentControl.frame = CGRectMake((PHONE_SCREEN_SIZE.width - width ) / 2.0, 10, width, 30);
	segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentControl.backgroundColor = [UIColor colorWithPatternImage:
									  [[RCResManager getInstance]imageForKey:@"button_bar"]];
	segmentControl.tintColor = self.navigationController.navigationBar.tintColor;
	NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithCapacity:5]; //设置字体风格
	[attributes setObject:[UIFont fontWithName:MED_HEITI_FONT size: 12] forKey:UITextAttributeFont];
	[segmentControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
	[segmentControl setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
	[segmentControl addTarget:self action:@selector(changeCurrentViewController:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView  = segmentControl;
	TT_RELEASE_SAFELY(segmentControl);
	
	
	CALayer *layer = self.view.layer;
	layer.borderWidth = 2;
	layer.borderColor = [[UIColor greenColor]CGColor];
	
	[self.view addSubview:self.hotShareController.view]; //热门分享
	[self.view addSubview:self.newsFeedController.view];//好友动态
	
//	//导航条
//	UIImageView *navBarView = [[[UIImageView alloc]initWithImage:[[RCResManager getInstance]imageForKey:@"button_bar"]]autorelease];
//	navBarView.userInteractionEnabled = YES;
//	navBarView.frame = CGRectMake(0, 0, PHONE_SCREEN_SIZE.width, PHONE_NAVIGATIONBAR_HEIGHT);
//	[navBarView addSubview: refreshButton];
//	[refreshButton release];
//	[self.view addSubview:navBarView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.	
	for (UIView * subview in self.view.subviews) {
		NSLog(@"subView name is %@ tag =  %d",NSStringFromClass(subview.class),subview.tag);
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated{

	[super viewWillAppear:animated];
//	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	
	//否则拖动下, 将要从他人的进入个人的新鲜事列表
    
//	[self.newsFeedController scrollViewDidScroll:self.newsFeedController.newsFeedTableView];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
	好友动态
 */
- (RNNewsFeedController *)newsFeedController{
	
	if (!_newsFeedController) {
		_newsFeedController = [[RNNewsFeedController alloc]init];
		_newsFeedController.view.frame = CGRectMake(0, 
													0, 
													PHONE_SCREEN_SIZE.width, 
													PHONE_SCREEN_SIZE.height);
		
		//用于push出另外一个界面
	
		_newsFeedController.parentController = self;
	}
	
	return _newsFeedController;
}

/*
	热门分享
 */
- (RNHotShareViewController *)hotShareController{
	
	if (!_hotShareController) {
		_hotShareController = [[RNHotShareViewController alloc]init];
		_hotShareController.view.frame = CGRectMake(0, 
														0, 
														PHONE_SCREEN_SIZE.width, 
														PHONE_SCREEN_SIZE.height);
		
		//用于push出另外一个界面
	    _hotShareController.parentController = self;
	}
	return _hotShareController;
}


#pragma mark - 刷新
- (void)onClickRefreshButton{
	
	if (_currentViewController == self.hotShareController) {
		[self.hotShareController.model load:YES];
	}else{
		[self.newsFeedController refreshData];
	}
	
}

/*
	改变浏览频道，是热门分享还是好友动态
 */
- (void)changeCurrentViewController:(UISegmentedControl *)sender{
	if (0 == sender.selectedSegmentIndex) {
		_currentViewController.view.hidden = YES;
		_currentViewController = self.newsFeedController;
		_currentViewController.view.hidden = NO;
//		self.title = @"好友动态";
	}else {
		_currentViewController.view.hidden = YES;
		_currentViewController = self.hotShareController;
		_currentViewController.view.hidden = NO;

//		self.title = @"热门分享";
	}
	
	[self.view bringSubviewToFront:_currentViewController.view];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touchsBegan : ");
	
}
@end
