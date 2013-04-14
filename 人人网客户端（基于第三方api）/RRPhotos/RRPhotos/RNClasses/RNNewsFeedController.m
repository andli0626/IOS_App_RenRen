//
//  RNNewsFeedController.m
//  RRPhotos
//
//  Created by yi chen on 12-4-8.
//  Copyright (c) 2012年 renren. All rights reserved.
//
#import <objc/runtime.h>
#import "RNNewsFeedController.h"
#import "RNAlbumWaterViewController.h"
#import "RNPhotoViewController.h"
#define kHotShareViewTag 10001
#define kNewsFeedViewTag 10002
#define kHudViewTag 10004
@interface RNNewsFeedController ()
//显示正在加载
- (void)showMBProgressHUD;
//隐藏正则加载
- (void)hiddenMBProgressHUD;
@end

@implementation RNNewsFeedController
@synthesize newsFeedTableView = _newFeedTableView;
@synthesize rrRefreshTableHeaderView = _rrRefreshTableHeaderView;
@synthesize parentController = _parentController;
@synthesize userId = _userId;
@synthesize userName = _userName;
@synthesize bIsSelfPage = _bIsSelfPage;
- (void)dealloc{
	self.newsFeedTableView = nil;
	self.rrRefreshTableHeaderView = nil;
	self.parentController = nil;
	self.userId = nil;
	self.userName = nil;

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
/*
	@userId:用户的id
 */
- (id)initWithUserId:(NSNumber *)userId{
	if (userId) {
		self.userId = userId;
	}
	if (self = [super init]) {
		
	}
	return self;
}
	
- (id)initWithUserId:(NSNumber *)userId userName:(NSString *)userName{
	
	if (self = [self initWithUserId:userId]) {
		if (userName) {
			self.userName = userName;
		}
	}
	return self;
}

/*
	指示是否是自己的页面
 */
- (BOOL)bIsSelfPage{
	
	if (self.userId && ![self.userId isEqualToNumber:[RCMainUser getInstance].userId]) {
		return NO;
	}
	
	return YES;
}

/*
	点击刷新按钮
 */
- (void)onClickRefreshButton{
	
	
	[self refreshData];
}
/*
	图片新鲜事内容表
 */
- (UITableView *)newsFeedTableView{
	if (!_newFeedTableView) {
		//新鲜事表
		UITableView *newsFeedTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 
																					  44, 
																					  PHONE_SCREEN_SIZE.width, 
																					  PHONE_SCREEN_SIZE.height - 44)];
		if (!self.bIsSelfPage) {
			newsFeedTableView.frame = CGRectMake(0, 
												 0,  
												 PHONE_SCREEN_SIZE.width, 
												 PHONE_SCREEN_SIZE.height);
		}
		
		newsFeedTableView.backgroundColor = kNewsFeedTableViewBgColor;
		newsFeedTableView.dataSource = self; //tableView的数据
		newsFeedTableView.delegate = self;
		UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320,200)];
		footerView.backgroundColor = [UIColor clearColor];
		newsFeedTableView.tableFooterView = footerView;
		TT_RELEASE_SAFELY(footerView);
		[self.view addSubview:newsFeedTableView];
		_newFeedTableView = newsFeedTableView;

//		CALayer *layer = _newFeedTableView.layer;
//		layer.borderWidth = 5;
//		layer.borderColor = [[UIColor blueColor]CGColor];
	}
	return _newFeedTableView;
}

/*
	下拉刷新头部
 */
- (RRRefreshTableHeaderView *)rrRefreshTableHeaderView{
	
	//下拉刷新
	if (_rrRefreshTableHeaderView == nil) {
		RRRefreshTableHeaderView *view = [[RRRefreshTableHeaderView alloc]
										  initWithFrame:CGRectMake(0.0f,
																   0.0f - self.newsFeedTableView.bounds.size.height,
																   PHONE_SCREEN_SIZE.width,
																   self.newsFeedTableView.bounds.size.height)];
		view.delegate = self;
		[self.newsFeedTableView addSubview:view];
		_rrRefreshTableHeaderView = view;
		view.backgroundColor = kNewsFeedTableViewBgColor;
		
		[_rrRefreshTableHeaderView refreshLastUpdatedDate];
		_bIsLoading = NO; //是否正在加载标记
	}

	return _rrRefreshTableHeaderView;
}
#pragma mark - viewlife 
- (void)loadView{
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	self.view.userInteractionEnabled = YES;
	self.navigationController.navigationBar.userInteractionEnabled = YES;
	self.navBar.userInteractionEnabled = YES;
	self.newsFeedTableView.userInteractionEnabled = YES;
	self.parentController.navigationController.navigationBar.userInteractionEnabled = YES;
	self.navBar.hidden = YES; //采用系统的navbar
	if (self.userName) {
		self.title = self.userName;
	}
	
	[self.view addSubview:self.newsFeedTableView];
	[self.view bringSubviewToFront:self.newsFeedTableView];
	
	UIView *testView  = [[UIView alloc]initWithFrame:CGRectMake(0, - 44, 44, 44)];
	testView.backgroundColor = [UIColor blueColor];
	testView.userInteractionEnabled = YES;
	[self.view addSubview:testView];
	[testView release];
	
//	CALayer *layer = self.view.layer;
//	layer.borderWidth = 3;
//	layer.borderColor = [[UIColor redColor]CGColor];
	
	
	//刷新按钮
	UIButton *refreshButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	UIImage *refreshButtonImage = [[RCResManager getInstance]imageForKey:@"webbrowser_refresh"];
	[refreshButton setImage:refreshButtonImage forState:UIControlStateNormal];
	[refreshButton setImage:refreshButtonImage forState:UIControlStateSelected];
	[refreshButton addTarget:self action:@selector(onClickRefreshButton) forControlEvents:UIControlEventTouchUpInside];
	
	if (self.bIsSelfPage) {
		//导航条
		refreshButton.frame = CGRectMake( 280, 7, 30, 30);
		UIImageView *navBarView = [[[UIImageView alloc]initWithImage:[[RCResManager getInstance]imageForKey:@"button_bar"]]autorelease];
		navBarView.userInteractionEnabled = YES;
		navBarView.frame = CGRectMake(0, 0, PHONE_SCREEN_SIZE.width, PHONE_NAVIGATIONBAR_HEIGHT);
		[navBarView addSubview: refreshButton];
		[refreshButton release];
		[self.view addSubview:navBarView];
	}else {
		
		UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:refreshButton];
		[refreshButton release];
		self.navigationItem.rightBarButtonItem = item;
	}
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.newsFeedTableView = nil;
	self.rrRefreshTableHeaderView = nil;
	
}


- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];

	if (!self.bIsSelfPage) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];

	}else {
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	if (!self.bIsSelfPage) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}else {
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}

}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	if (!self.bIsSelfPage) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}else {
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
}
#pragma mark - 网络
/*
	重载父类的创建model
 */
- (void)createModel {
	
	//新鲜事类型
	NSString *typeString = ITEM_TYPES_NEWSFEED_FOR_PHOTO;//只请求与照片有关的数据
	RNNewsFeedModel *model = nil;

	if (self.userId) {
		NSLog(@"userid = %@",self.userId);
		//某个指定id的新鲜事
		model = [[RNNewsFeedModel alloc]initWithTypeString:typeString 
											userId:self.userId];

	}else {
		//自己的新鲜事
		model = [[RNNewsFeedModel alloc]initWithTypeString:typeString];
	}

	self.model = (RNModel *) model;
	[self.model load:YES];//加载数据
}


/*
	显示加载进度圈圈
 */

- (void)showMBProgressHUD{
	if ([self.view viewWithTag:kHudViewTag]) {
		UIView *hudView = [self.view viewWithTag:kHudViewTag];
		[self.view bringSubviewToFront:hudView];
		hudView.hidden = NO;
		return;
	}
	MBProgressHUD *hudView =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hudView.frame = CGRectMake(0 ,0, 320 ,411); //布局问题的bug，进度圈圈不显示，只能强制加上这句话
	
	hudView.tag = kHudViewTag;
	hudView.labelText = @"正加载";	
	hudView.square = YES;
	hudView.opaque = 0.6;
	
	[self.view bringSubviewToFront:hudView];
	[hudView becomeFirstResponder];
}

/*
	隐藏加载圈圈
 */
- (void)hiddenMBProgressHUD{
	//移除进度圈圈
	UIView *hudView = [self.view viewWithTag:kHudViewTag];
	hudView.hidden = YES;
	[hudView resignFirstResponder];
}


/*
	开始
 */
- (void)modelDidStartLoad:(RNModel *)model {
	_bIsLoading = YES;
	
	[self showMBProgressHUD];
}

- (void)modelDidFinishLoad:(RNModel *)model{
	
	
    [_newFeedTableView reloadData];
	_bIsLoading = NO; //正在刷新标记NO
	[self hiddenMBProgressHUD];

	[self.rrRefreshTableHeaderView rrRefreshScrollViewDataSourceDidFinishedLoading:self.newsFeedTableView];
}

#pragma mark - 刷新

/*
	刷新数据
 */
- (void)refreshData{
	if (_bIsLoading) {
		return;
	}
	
	[UIView animateWithDuration:0.3 animations:^() {
		NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.newsFeedTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		[self.newsFeedTableView setContentOffset : CGPointMake(0, - 150) animated:NO];
	} completion:^(BOOL finished){
		if (finished) {
			[self.rrRefreshTableHeaderView setState:RROPullRefreshPulling];
			[self.rrRefreshTableHeaderView rrRefreshScrollViewDidScroll:self.newsFeedTableView];
			[self.rrRefreshTableHeaderView rrRefreshScrollViewDidEndDragging:self.newsFeedTableView];
		}
	}];
}
#pragma mark - UITableViewDataSource
//@required

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//	return 1;
	return ((RNNewsFeedModel *)self.model).newsFeedCount;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
//	return ((RNNewsFeedModel *)self.model).newsFeedCount;
	return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	RRNewsFeedItem *item = [[(RNNewsFeedModel *)self.model newsFeeds]objectAtIndex:section];
	RNNewsFeedSectionView *sectionView = [[RNNewsFeedSectionView alloc]initWithItem:item];
	sectionView.delegate = self;
	return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *cellIdentifier  = @"newsFeedCell";
	
	RNNewsFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	NSLog(@"row = %d",indexPath.row);
	
	if (!cell) {
		cell = [[[RNNewsFeedCell alloc]initWithStyle:UITableViewCellStyleDefault 
									 reuseIdentifier:cellIdentifier]autorelease];
		cell.delegate = self;
	}
	RRNewsFeedItem *item = [[(RNNewsFeedModel *)self.model newsFeeds]objectAtIndex:indexPath.section];
	[cell setCellWithItem:item]; 
	
	cell.contentView.backgroundColor = kNewsFeedTableViewBgColor;

	//	cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
	return cell;	
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return PHONE_NAVIGATIONBAR_HEIGHT; //44
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

	return [self tableView: self.newsFeedTableView cellForRowAtIndexPath:indexPath].height;
}


#pragma mark - UIScrollViewDelegate Methods

/*
	调整视图位置，让sectionview处于导航栏的位置
 */
- (void)resetViewLocation:(NSInteger)offsetY{
	//将整个view 上下移
	offsetY = offsetY < kNewsFeedSectionViewHeight ? offsetY : kNewsFeedSectionViewHeight;

	CGRect r = self.view.frame;
	r = CGRectMake(0, - offsetY, r.size.width, r.size.height + offsetY);
	self.view.frame = r;
	
}

/*	
	视图正在拖动
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	if (self.bIsSelfPage) {
		//如果是自己的主页
		NSInteger offsetY = scrollView.contentOffset.y;
		if (offsetY < 0 ) {
			//导航条复位
			[self resetViewLocation:0];	
			[self.rrRefreshTableHeaderView rrRefreshScrollViewDidScroll:scrollView];
		}else{
			[self resetViewLocation:offsetY];
		}
	}else {
		//通知下拉刷新
	}
	
	[self.rrRefreshTableHeaderView rrRefreshScrollViewDidScroll:scrollView];

}

/*
	视图拖动结束，但是仍然继续滑动
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	// 拖动结束
	if (!self.userId) {
		NSInteger offsetY = scrollView.contentOffset.y;
		if (offsetY < 0 ) {
			//导航条复位
			[self resetViewLocation:0];	
		}else {
			
			[self resetViewLocation:offsetY];		
		}
	}
	
	[self.rrRefreshTableHeaderView rrRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - RRRefreshTableHeaderDelegate Methods

- (void)rrRefreshTableHeaderDidTriggerRefresh:(RRRefreshTableHeaderView*)view{
	if (_bIsLoading) {
		return;
	}
	
	[self.model load:YES];// 加载数据
	_bIsLoading = YES;
}

- (BOOL)rrRefreshTableHeaderDataSourceIsLoading:(RRRefreshTableHeaderView*)view{
	return  _bIsLoading;
}

- (NSDate*)rrRefreshTableHeaderDataSourceLastUpdated:(RRRefreshTableHeaderView*)view
{	
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - RNNewsFeedCellDelegate

/*
	点击新鲜事附件照片,查看照片
 */
- (void)onTapAttachView: (NSNumber *)userId photoId:(NSNumber *)photoId {
	if (userId && photoId) {
		NSString *userIdStr = [userId stringValue];
		NSString *photoIdStr = [photoId stringValue];
		RNPhotoViewController *viewController = [[RNPhotoViewController alloc]initWithUid:userIdStr
																				  withPid:photoIdStr
																				  shareId:nil 
																				 shareUid:nil];
		
		NSLog(@"进入照片内容页");
		//此处用AppDelegate presentModalViewController 否则支持横竖屏会有问题
		AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

		[appDelegate.mainViewController presentModalViewController:viewController animated:NO];
		TT_RELEASE_SAFELY(viewController);

	}
}

#pragma mark - RNNewsFeedSectionViewDelegate
/*
	点击新鲜事标题,即相册名称,进入相册内容页
 */
- (void)onTapTitleLabel: (NSNumber *)userId albumId: (NSNumber *)photoId {
	if (userId && photoId) {
		NSMutableDictionary* dics = [NSMutableDictionary dictionary];
		[dics setObject:[RCMainUser getInstance].sessionKey forKey:@"session_key"];
		[dics setObject:photoId forKey:@"pid"];
		[dics setObject:userId forKey:@"uid"];
		
		RCGeneralRequestAssistant *mReqAssistant = [RCGeneralRequestAssistant requestAssistant];
		//    __block typeof(self) self = self;
		mReqAssistant.onCompletion = ^(NSDictionary* result){
			NSNumber *albumId = [result objectForKey:@"album_id"];
			RNAlbumWaterViewController *viewController = [[RNAlbumWaterViewController alloc]initWithUid:userId
																								albumId:albumId];

			viewController.hidesBottomBarWhenPushed = YES;
			NSLog(@"cy ----------%@",self.parentController.navigationController);
			if (self.navigationController) {
				[self.navigationController pushViewController:viewController animated:YES];
			}else {
				[self.parentController.navigationController pushViewController:viewController animated:YES];
			}
			NSLog(@"cy-------------进入相册内容页");
			//查看相册
			TT_RELEASE_SAFELY(viewController);
		};
		mReqAssistant.onError = ^(RCError* error) {
			NSLog(@"error....%@",error.titleForError);
			UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"网络加载错误" 
																message:nil 
															   delegate:nil 
													  cancelButtonTitle:@"确定" 
													  otherButtonTitles:nil];
			[errorAlert show];
			TT_RELEASE_SAFELY(errorAlert);
		};
		[mReqAssistant sendQuery:dics withMethod:@"photos/get"];
	}

}

/*
	点击头像,进入某个用户的个人主页
 */
- (void)onTapHeadImageView:(NSNumber *)userId userName:(NSString *)userName{
	if (!userId) {
		return;
	}
	
	RNNewsFeedController *newsFeedController = [[RNNewsFeedController alloc]initWithUserId:userId userName:userName];
	newsFeedController.hidesBottomBarWhenPushed = YES;
	newsFeedController.parentController = self.parentController;
	if (self.parentController) {
		[self.parentController.navigationController pushViewController:newsFeedController animated:YES];
	}else {
		[self.navigationController pushViewController:newsFeedController animated:YES];
	}
	TT_RELEASE_SAFELY(newsFeedController);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touch begin");

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touch end");
}
@end
