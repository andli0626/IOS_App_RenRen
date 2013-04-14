//
//  RNPoiListViewController.m
//  RRSpring
//
//  Created by yi chen on 12-4-14.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPoiListViewController.h"
//#import "RNSearchDisplayController.h"
//列表的背景色
#define kPOITableViewBgColor (RGBCOLOR(246, 246, 246))
#define kPoiSearchPauseInterval 0.5
#define kPoiCellIndiactorTag 10000

@interface  RNPoiListViewController()

- (void)getLocationInfoFromCache:(BOOL)isForce;

- (void)getLocationInfoFromNet;
@end

@implementation RNPoiListViewController
@synthesize delegate = _delegete;
@synthesize poiItemsAll = _poiItemsAll;
@synthesize poiItemsCache = _poiItemsCache;
@synthesize poiItemsNet = _poiItemsNet;
@synthesize poiItemsSearchResult = _poiItemsSearchResult;
@synthesize rrRefreshTableHeaderView = _rrRefreshTableHeaderView;
@synthesize indicator = _indicator;
@synthesize rrSearchDisplayController = _rrSearchDisplayController;
@synthesize longitude = _longitude;
@synthesize latitude = _latitude;

- (void)dealloc{
	self.delegate = nil;
	self.poiItemsAll = nil;
	self.poiItemsCache = nil;
	self.poiItemsNet = nil;
	self.poiItemsSearchResult = nil;
	self.rrRefreshTableHeaderView = nil;
	self.indicator = nil;
	self.rrSearchDisplayController = nil;
	RL_INVALIDATE_TIMER(_pauseTimer);

	self.longitude = nil;
	self.latitude = nil;
	
	[super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_poiItemsAll = [[NSMutableArray alloc]init];
		_poiItemsSearchResult = [[NSMutableArray alloc]init ];
    }
    return self;
}


#pragma mark - view lifecycle
- (void)loadView{
	[super loadView];
	
	self.accessoryBar.title = NSLocalizedString(@"选择地点", @"选择地点");
	self.accessoryBar.rightButtonEnable = NO;
	
	if (self.tableView) {
		//列表初始化
		self.tableView.frame  = CGRectMake(0, 
										   CONTENT_NAVIGATIONBAR_HEIGHT,
										   PHONE_SCREEN_SIZE.width,
										   PHONE_SCREEN_SIZE.height - CONTENT_NAVIGATIONBAR_HEIGHT);
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.tableView.backgroundColor = kPOITableViewBgColor;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		//搜索框
		UISearchBar* searchBar = [[[UISearchBar alloc] init] autorelease];
        [searchBar setBackgroundImage:[[RCResManager getInstance]imageForKey:@"rn_main_search_bg"]];
        [searchBar sizeToFit];

		UISearchDisplayController * searchDisplayController = [[UISearchDisplayController alloc]
															   initWithSearchBar:searchBar 
															   contentsController:(UIViewController *)self];
		
		searchDisplayController.searchBar.frame = CGRectMake(0,0, 
													   searchDisplayController.searchBar.frame.size.width,
													   searchDisplayController.searchBar.frame.size.height);
		searchDisplayController.searchBar.placeholder = NSLocalizedString(@"搜索或者创建附近地点", @"搜索或者创建附近地点");

		searchDisplayController.delegate = self;
		searchDisplayController.searchResultsDelegate = self;
		searchDisplayController.searchResultsDataSource = self;
		self.rrSearchDisplayController = searchDisplayController;
		self.tableView.tableHeaderView = searchDisplayController.searchBar;
		_pausesBeforeSearching = YES; //是否开启搜索延迟定时器
		TT_RELEASE_SAFELY(searchDisplayController);
		
		//下拉刷新
		if (_rrRefreshTableHeaderView == nil) {
			RRRefreshTableHeaderView *view = [[RRRefreshTableHeaderView alloc]
											  initWithFrame:CGRectMake(0.0f,
																	   0.0f - self.tableView.bounds.size.height,
																	   PHONE_SCREEN_SIZE.width,
																	   self.tableView.bounds.size.height)];
			view.delegate = self;
			[self.tableView addSubview:view];
			self.rrRefreshTableHeaderView = view;
			TT_RELEASE_SAFELY(view);
		}
		[_rrRefreshTableHeaderView refreshLastUpdatedDate];
		_bIsLoading = NO;
	}
	
	//导入缓存数据
	[self getLocationInfoFromCache:NO];
}

- (void)viewDidLoad{
	[super viewDidLoad];
}

- (void)viewDidUnload{
	[super viewDidUnload];
	
	self.delegate = nil;
	self.poiItemsAll = nil;
	self.poiItemsCache = nil;
	self.poiItemsNet = nil;
	self.poiItemsSearchResult = nil;
	self.rrRefreshTableHeaderView = nil;
	self.indicator = nil;
	self.rrSearchDisplayController = nil;
	RL_INVALIDATE_TIMER(_pauseTimer);

	self.longitude = nil;
	self.latitude = nil;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - 创建model
/*
	创建网络model
 */
- (void)createModel{
	RNPoiListModel *poiModel = [[RNPoiListModel alloc]init]; //这里数据量比较简单，就不需要定义一个新的model了
	self.model = poiModel;
	TT_RELEASE_SAFELY(poiModel);
}

#pragma mark - RNModelDelegate
// 开始
- (void)modelDidStartLoad:(RNModel *)model {
	[self.indicator startAnimating];
}

// 完成
- (void)modelDidFinishLoad:(RNModel *)model {
	if (!model) {
		return;
	}
	
	//处理成功的数据
	self.poiItemsNet = [(RNPoiListModel *)self.model items];
	
	[self.poiItemsAll removeAllObjects];
	[self.poiItemsAll addObjectsFromArray:self.poiItemsCache];
	[self.poiItemsAll addObjectsFromArray:self.poiItemsNet];
	
	[self.indicator stopAnimating]; //指示器停止显示
	[self.tableView reloadData];
	
}

// 错误处理
- (void)model:(RNModel *)model didFailLoadWithError:(RCError *)error {
	NSLog(@"网络请求poi列表失败");
	[self.indicator stopAnimating]; //指示器停止显示

}

// 取消
- (void)modelDidCancelLoad:(RNModel *)model {
	[self.indicator stopAnimating]; //指示器停止显示

}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return kPoidCellHeigth;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSMutableDictionary *itemInfoDic;
	if (tableView == self.rrSearchDisplayController.searchResultsTableView) { //如果是搜索结果的tableview
		itemInfoDic  = [self.poiItemsSearchResult objectAtIndex:indexPath.row];

	}else { //全部poi的tableview
		
		if (indexPath.row == [self.poiItemsAll count] ) { //加载更多
			
			[self getLocationInfoFromNet];
			return;
		}else if (indexPath.row == [self.poiItemsAll count] + 1){ //创建一个poi
			
			NSMutableDictionary *poiInfoDic = [NSMutableDictionary dictionary];
			if (self.longitude && self.latitude) {
				[poiInfoDic setObject:self.longitude forKey:@"lon_gps"];//经度
				[poiInfoDic setObject:self.latitude forKey:@"lat_gps"]; //纬度
			}
			
			//使用的是否是真实经纬度，若是，则设1，若已经使用的是偏转过的经纬度，则设为0
			[poiInfoDic setObject:[NSNumber numberWithInt:0] forKey:@"d"];
			
		    RNCreatePoiViewController *createPoiViewController = [[RNCreatePoiViewController alloc]
																  initWithPoiInfoDic:poiInfoDic ];
			[self presentModalViewController:createPoiViewController animated:YES];
			TT_RELEASE_SAFELY(createPoiViewController);
			
			return;
		}else {
			itemInfoDic = [self.poiItemsAll objectAtIndex:indexPath.row];
		}
	}
	
	if (itemInfoDic) {
		NSNumber *lon = [itemInfoDic objectForKey:@"lon"];
		NSNumber *lat = [itemInfoDic objectForKey:@"lat"];
		NSString *poi_name = [itemInfoDic objectForKey:@"poi_name"];
		NSString *pid = [itemInfoDic objectForKey:@"pid"];
		
		//信息返回
		NSMutableDictionary *itemInfoReturnDic = [NSMutableDictionary dictionaryWithCapacity:10];
		[itemInfoReturnDic setObject:lon forKey:@"gps_longitude"];
		[itemInfoReturnDic setObject:lat forKey:@"gps_latitude"];
		[itemInfoReturnDic setObject:poi_name forKey:@"place_name"];
		[itemInfoReturnDic setObject:pid forKey:@"place_id"];
		if (self.delegate) {
			if ([self.delegate respondsToSelector:@selector(didSlectedPoiItem:)]) {
				[self.delegate didSlectedPoiItem:itemInfoReturnDic];
			}
		}
		
	}
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (self.rrSearchDisplayController.searchResultsTableView == tableView) {
		 return NSLocalizedString(@"搜索结果", @"搜索结果");
	}

	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (tableView == self.rrSearchDisplayController.searchResultsTableView) {
		//经过搜索过滤之后的数据
		return [self.poiItemsSearchResult count];
	}else { 
		//原始数据
		return [self.poiItemsAll count] + 2; //多两个cell:1.加载更多，2.创建poi
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}// Default is 1 if not implemented

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
		
	/* 经过搜索过滤的数据 */
	if (self.rrSearchDisplayController.searchResultsTableView == tableView) {
		static NSString *cellIdentifierSearchResult = @"poiCellIdentifierSearchResult";
		RNPoiListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSearchResult];  

		if (!cell) {
			cell = [[[RNPoiListCell alloc]initWithStyle:UITableViewCellStyleDefault
										reuseIdentifier:cellIdentifierSearchResult]autorelease];
		}
		
		//将poi列表写入每个cell
		NSDictionary *poiCellInfoDic;
		if (self.poiItemsSearchResult) {
			poiCellInfoDic = [[[NSDictionary alloc]initWithDictionary:
							   (NSDictionary *)[self.poiItemsSearchResult objectAtIndex:indexPath.row]]autorelease];
		}
		[(RNPoiListCell *)cell setWithPoiCellInfoDic: poiCellInfoDic];

		return cell;
	}
	
	static NSString *cellIdentifier = @"poiCellIdentifier";
	RNPoiListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];  

	/* 原始列表的数据 */
	if ( [self.poiItemsAll count] ==  indexPath.row) {
		if (!cell) {
			cell = [[[RNPoiListCell alloc]initWithStyle:UITableViewCellStyleDefault 
										  reuseIdentifier:cellIdentifier]autorelease];
		}
		[cell.contentView removeAllSubviews];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = NSLocalizedString(@"查看更多地点", @"查看更多地点");
		cell.textLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:12];
		cell.textLabel.textColor = [UIColor blueColor];
		
		//添加一个指示器
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
											  initWithFrame:CGRectMake(5, 10, 35, 35)];
		indicator.tag = kPoiCellIndiactorTag;
		indicator.hidesWhenStopped = YES;
		indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		[cell.contentView addSubview:indicator];
		self.indicator = indicator;
		TT_RELEASE_SAFELY(indicator);
		
	}else if ([self.poiItemsAll count] + 1 == indexPath.row) {
		if (!cell) {
			cell = [[[RNPoiListCell alloc]initWithStyle:UITableViewCellStyleDefault 
										reuseIdentifier:cellIdentifier]autorelease];
		}
		[cell.contentView removeAllSubviews];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = NSLocalizedString(@"没有所在地点,立即创建并报道", @"没有所在地点,立即创建并报道");
		cell.textLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:12];
		cell.textLabel.textColor = [UIColor blueColor];
		
		if ([cell viewWithTag:kPoiCellIndiactorTag]) {
			[[cell viewWithTag:kPoiCellIndiactorTag] removeFromSuperview];
		}
	}else {
		if (!cell) {
			cell = [[[RNPoiListCell alloc]initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:cellIdentifier]autorelease];
		}
		cell.textLabel.text = @""; //清空显示
		if ([cell viewWithTag:kPoiCellIndiactorTag]) {
			[[cell viewWithTag:kPoiCellIndiactorTag] removeFromSuperview];
		}
		
		//将poi列表写入每个cell
		NSDictionary *poiCellInfoDic;
		if (self.poiItemsAll) {
			poiCellInfoDic = [[[NSDictionary alloc]initWithDictionary:
								(NSDictionary *)[self.poiItemsAll objectAtIndex:indexPath.row]]autorelease];
		}
		[(RNPoiListCell *)cell setWithPoiCellInfoDic: poiCellInfoDic];
	
	}
	
	return cell;
}

#pragma mark - 获取poi列表
/*
	主动请求服务器的poi列表
 */
- (void)getLocationInfoFromNet{

	if (self.longitude && self.latitude) {
		//加载网络数据前，要先将预定位得到的经纬度传入
		//经度
		[self.model.query setObject:self.longitude forKey:@"lon_gps"];
		//纬度
		[self.model.query setObject:self.latitude forKey:@"lat_gps"];
	
		[self.model load: YES];
	}else {
		return;
	}
}

/*
	从缓存里面取poi数据
	如果isForced为true,则会直接去请求当前定位信息
 */
- (void)getLocationInfoFromCache:(BOOL)isForce
{
    RCLBSCacheManager* manager = [RCLBSCacheManager sharedInstance];
    if(manager){
        manager.delegate = self;
		[manager setKeepLocOpening:YES];
		if (isForce) {
			[manager updateLocation:YES]; //强制更新缓存
		}else {
			[manager getLocCache];
		}
    }
}


#pragma mark - RCLBSCacheManagerDelegate 
/*
	预定位成功回调
 */
- (void)preLocateFinished:(RCLocationCache*)location{
	if (!location) {
		return;
	}
	_bIsLoading = NO; //数据更新结束
    [_rrRefreshTableHeaderView rrRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];

	//存取缓存取来的poi列表
	self.poiItemsCache = location.poiListFirstPage;
	[self.poiItemsAll removeAllObjects];//清空数据
	[self.poiItemsAll addObjectsFromArray:self.poiItemsCache];
	
	//存取预定位的经纬度信息，用于创建poi地点请求使用
	self.longitude = location.longitude;
	self.latitude = location.latitude;
	
	[self.tableView reloadData];
}

/*
	预定位失败回调
 */
- (void)preLocateFailed:(RCError*)error{
	NSLog(@"cy ---------------预定位失败！！！！error : %@",error.titleForError);
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	//拖动
	if (self.rrSearchDisplayController.searchResultsTableView == scrollView) {
		
	}else {
		[self.rrRefreshTableHeaderView rrRefreshScrollViewDidScroll:scrollView];
	}
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	//拖动结束
	if (self.rrSearchDisplayController.searchResultsTableView == scrollView) {
		
	}else {
		[self.rrRefreshTableHeaderView rrRefreshScrollViewDidEndDragging:scrollView];
	}
}

#pragma mark - RRRefreshTableHeaderDelegate Methods

- (void)rrRefreshTableHeaderDidTriggerRefresh:(RRRefreshTableHeaderView*)view{
	[self getLocationInfoFromCache:YES]; //强制更新缓存
	_bIsLoading = YES;

}

- (BOOL)rrRefreshTableHeaderDataSourceIsLoading:(RRRefreshTableHeaderView*)view{
	return  _bIsLoading;
}

- (NSDate*)rrRefreshTableHeaderDataSourceLastUpdated:(RRRefreshTableHeaderView*)view
{	
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - search
/*
	搜索
 */
- (void)filterContentForSearchText:(NSString*)searchText 
{
//尝试用下正则表达 
//附加符号，[c],[d],[cd],c表示不区分大小写，d表示不区分发音字符，cd表示什么都不区分
//    NSPredicate *resultPredicate = [NSPredicate 
//                                    predicateWithFormat:@"(poi_name contains[cd] '%@')",searchText];
//	self.poiItemsSearchResult = [self.poiItemsAll  filteredArrayUsingPredicate:resultPredicate];

	for (id poiItem  in self.poiItemsAll) {
		if ([ poiItem isKindOfClass: NSDictionary.class]) {
			if (NSNotFound != [[poiItem objectForKey:@"poi_name"] rangeOfString:searchText 
																		options:NSCaseInsensitiveSearch].location ){
				
				NSDictionary *poiItemDic = [NSDictionary dictionaryWithDictionary:poiItem];
				[self.poiItemsSearchResult addObject:poiItemDic];
			}
		}
	}
	[self.rrSearchDisplayController.searchResultsTableView reloadData];
}

/* 
	重启搜索,将会开启定时器
 */
- (void)restartPauseTimer 
{
    RL_INVALIDATE_TIMER(_pauseTimer);
    _pauseTimer = [NSTimer scheduledTimerWithTimeInterval:kPoiSearchPauseInterval target:self
                                                 selector:@selector(searchAfterPause) userInfo:nil repeats:NO];
}

/*
	定时器结束之后,搜索ing
 */
- (void)searchAfterPause 
{
    _pauseTimer = nil;
	[self filterContentForSearchText:self.rrSearchDisplayController.searchBar.text];
}

/*
	重置搜索数据
 */
- (void)resetResults{
	[self.poiItemsSearchResult removeAllObjects];
}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayController:(UISearchDisplayController*)controller 
	willHideSearchResultsTableView:(UITableView*)tableView 
{
    [self resetResults];
}


- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController*)controller 
{
    [self resetResults];
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller 
	shouldReloadTableForSearchString:(NSString*)searchString 
{
    if (_pausesBeforeSearching) {
        [self restartPauseTimer];
        
    } else {
		[self filterContentForSearchText:controller.searchBar.text];
    }
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller
	shouldReloadTableForSearchScope:(NSInteger)searchOption 
{
	[self filterContentForSearchText:controller.searchBar.text];
    return NO;
}


/*
 * 点击左边取消按钮
 * 
 */
- (void)publisherAccessoryBarLeftButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    // 子类实现
	[self dismissModalViewControllerAnimated:YES];
}

@end
