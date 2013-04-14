//
//  AlbumViewController.m
//  RRSpring
//
//  Created by sheng siglea on 12-3-6.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RNAlbumWaterViewController.h"
#import "RNPhotoViewController.h"
#import "AppDelegate.h"
#import "RNUIActionSheet.h"
#import "RNPublisherViewController.h"
#import "RNCommentViewController.h"
//#import "RNUserHomeViewController.h"
//#import "RNFeedCommentViewController.h"

//默认宽高比
#define kDefaultWH 1.0
// 相册的密码长度
#define PASSWORD_TEXT_LENGTH 16
// 加载数据 activity指示
#define kTagActivity 2000

@interface RNAlbumWaterViewController()

@property (nonatomic, copy) NSNumber *userId;
@property (nonatomic, copy) NSNumber *albumId;
@property (nonatomic, retain) UIAlertView *tAlert;
@property (nonatomic, retain) UITextField *tInputPassword;

// 加载cell图片
- (void)requestImageData:(RNWaterFlowCell *)cell;
// wifi 使用200 W 图，3G使用 100 W 图
- (NSString *)suitableImageUrl:(RNPhotoItem *)item;
// self.model 强转为 子类型
- (RNPhotoListModel *)photoListModel;
// 显示数据加载指示
- (void)showDataIndicator;
// 加载相册信息
- (void)requestAlbumInfo;
// 展示右侧相关按钮
- (void)loadRightButtons;
//上传照片
- (void)uploadPhoto:(id)sender;
//分享相册
- (void)shareAlbum:(id)sender;
//收藏相册
- (void)favAlbum:(id)sender;
//查看原作者
- (void)lookupAuthor:(id)sender;  
//展示密码输入框
- (void)showAlertForPwd;
// 显示简单提示
- (void)showSimpleHUD:(NSString *)tip;
@end

@implementation RNAlbumWaterViewController

@synthesize userId = _userId;
@synthesize albumId = _albumId;
@synthesize tAlert = _tAlert;
@synthesize tInputPassword = _tInputPassword;

- (id)init{
    self = [super init];
    if (self) {
        _networkEngine = [[MKNetworkEngine alloc] init];
        [_networkEngine useCache];
        _invokeIndex = -1;
        _wrongPwdTimes = 0;
        _mainUser = [RCMainUser getInstance];
        _startSource = AlbumStartSourcePage;
        _networkStatus = -1;
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(reachabilityChanged:) 
                                                     name:kReachabilityChangedNotification 
                                                   object:nil];
        Reachability *r = [Reachability reachabilityWithHostname:@"www.renren.com"];
        [r startNotifier];
        _networkStatus = [r currentReachabilityStatus];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self 
//                                                 selector:@selector(uploadPhotoSuccess:) 
//                                                     name:kUploadPhotoSuccessNotification 
//                                                   object:nil];
        
    }
    return self;
}
- (id)initWithUid:(NSNumber *)uid albumId:(NSNumber *)aid{
    self = [self init];
    if (self) {
        self.userId = uid;
        self.albumId = aid;
        [self photoListModel].userId = self.userId;
        [self photoListModel].albumId = self.albumId;
    }
    return self;
}
- (id)initWithUid:(NSString *)uid albumId:(NSString *)aid shareId:(NSString *)sid shareUid:(NSString *)suid{
    if (self = [self initWithUid:(NSNumber *)uid albumId:(NSNumber *)aid]) {
        _shareId = [(NSNumber *)sid copy];
        _shareUid = [(NSNumber *)suid copy];
        _startSource = AlbumStartSourceShare;
    }
    return self;
}
- (id)initWithPhotoesData:(RNPhotoListModel *)pmodel withAlbum:(RNAlbumItem *)albumItem{
    if (self = [self init]) {
        self.userId = pmodel.userId;
        self.albumId = pmodel.albumId;
        _albumInfo = [albumItem retain];
        self.model = pmodel;
        _startSource = AlbumStartSourceShare;
    }
    return self;
}
//-(id)initWithURLAction:(HummerURLAction *)action{
//    NSDictionary *dics = action.pathParseResult;
//    if(dics){
//        if([dics count]>=2){
//            NSString *ownerId = [dics objectForKey:@"ownerId"];
//            NSString *aid = [dics objectForKey:@"albumId"];
//            NSString *sourceId = [dics objectForKey:@"sourceId"];
//            NSString *shareId = [dics objectForKey:@"shareId"];
//            NSString *sourceUserId = [dics objectForKey:@"sourceUserId"];
//            if(shareId){
//                self = [self initWithUid:sourceUserId albumId:sourceId shareId:shareId shareUid:ownerId];
//            }else {
//                self = [self initWithUid:(NSNumber *)ownerId albumId:(NSNumber *)aid];
//            }
//            return self;
//        }
//    }
//    return nil;
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 */
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithRed:.96471 green:.96471 blue:.96471 alpha:1];
    _flowView = [[RNWaterFlowView alloc] initWithFrame:CGRectMake(2, CONTENT_NAVIGATIONBAR_HEIGHT,
                                                                  320 - 4, 460 - CONTENT_NAVIGATIONBAR_HEIGHT - 48)];
    _flowView.flowdelegate = self;
    _flowView.showsVerticalScrollIndicator = NO;
    _flowView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_flowView];
    
    UIView *view = [[UIView alloc] initWithFrame:self.navBar.frame];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
    [view release];
    
    self.navBar.backgroundView.image = [[RCResManager getInstance] imageForKey:@"photo_narbar_bg"];
    [self.navBar.backButton setImage:[[RCResManager getInstance] imageForKey:@"photo_narbar_back"] 
							forState:UIControlStateNormal];
    [self.navBar.backButton setImage:[[RCResManager getInstance] imageForKey:@"photo_narbar_back"] 
							forState:UIControlStateHighlighted];
	[self.navBar.backButton addTarget: self action:@selector(backButtonAction)  
					 forControlEvents:UIControlEventTouchUpInside];

    _nextPageFooterView = [[RRNextPageFooterView alloc] initWithFrame:CGRectMake(0, _flowView.contentSize.height, 
                                                                                 _flowView.contentSize.width, 200)];
	[_flowView addSubview:_nextPageFooterView];	
	_nextPageFooterView.hidden = YES;	
    
    _fullScreenView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [self.view addSubview:_fullScreenView];
   
    _fullScreenView.hidden = YES;
    [self.view bringSubviewToFront:_fullScreenView];
    _fullScreenView.contentSize = CGSizeZero;
    _fullScreenView.backgroundColor = [UIColor clearColor];
    
}
- (void)viewDidLoad{
    [super viewDidLoad];
    if (_albumInfo) {
        [self loadRightButtons];
    }else {
        [self requestAlbumInfo];
    }
    if ([self.photoListModel.items count] > 0) {
        [_flowView reloadData];
    }else {
        [self load:NO];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	
	//chenyi add
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	//////////
	
    self.navBar.frame = CGRectMake(0, 0, 320, CONTENT_NAVIGATIONBAR_HEIGHT);
    if (_miniPublisherView) {
        _miniPublisherView.frame = CGRectMake(0, 460 - 48, 320, 48);
        [_miniPublisherView pullViewDown];
        _miniPublisherView.hidden = NO;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_invokeIndex == -1) {
        _fullScreenView.hidden = YES;
        _fullScreenView.contentSize = CGSizeZero;
        return;
    }
    RNWaterFlowCell *cell = [_flowView cellForIndex:_invokeIndex];
    
    CGFloat y = cell.origin.y - _flowView.contentOffset.y + _flowView.origin.y;
    CGFloat x = cell.origin.x;
    
    
    UIImageView *imageView = (UIImageView *)[_fullScreenView viewWithTag:9999];
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.tag = 9999;
        [_fullScreenView addSubview:imageView];
        [imageView release];
    }
    imageView.image = cell.imageView.image;
    _fullScreenView.backgroundColor = [UIColor blackColor];
    
    CGFloat height = (320 * imageView.image.size.height)/imageView.image.size.width;
    _fullScreenView.frame = CGRectMake(0, -20, 320, 480);
    _fullScreenView.contentSize = CGSizeMake(320, height > 480 ? height : 480);
    if (height>480) {
        imageView.frame = CGRectMake(0, 0, 320, height);
    }else {
        imageView.frame = CGRectMake(0, (480 - height)/2, 320, height);
    }
    
    _fullScreenView.hidden = NO;
    [UIView animateWithDuration:.3 
                     animations:^{
                         _fullScreenView.frame = CGRectMake(x, y, cell.width, cell.height);
                         CGFloat sHeight = (_fullScreenView.width * imageView.image.size.height)/imageView.image.size.width;
                         imageView.frame = CGRectMake(0, (cell.height - sHeight)/2, cell.width, sHeight);
                     } 
                     completion:^(BOOL finished) {
                         _fullScreenView.hidden = YES;
                         _fullScreenView.contentSize = CGSizeZero;
                     }];
    [UIView commitAnimations];
    _invokeIndex = -1;
}
- (void)viewDidUnload{
    [_flowView release];
    [_nextPageFooterView release];
    [_fullScreenView release];
    [_miniPublisherView release];
    [self viewDidUnload];
}
- (void)dealloc{
    RN_DEBUG_LOG;
    NSLog(@"------%d",self.retainCount);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.albumId = nil;
    self.userId = nil;
    [_networkEngine release];
    [_albumInfo release];
    [_mainUser release];
    [super dealloc];
    
}
#pragma reachabilityChanged
- (void) reachabilityChanged: (NSNotification* )note
{
    
    Reachability* r = [note object];
    _networkStatus = [r currentReachabilityStatus];
    
}
#pragma RNWaterFlowViewDelegate

- (NSUInteger)numberOfColumnsInFlowView:(RNWaterFlowView *)flowView{
    return 3;   
}
- (NSUInteger)numberofCellsInFlowView:(RNWaterFlowView *)flowView{
    return  [[self photoListModel].items count];
}
- (NSUInteger)columsSpan:(RNWaterFlowView *)flowView{
    return 3;
}
- (NSUInteger)rowSpan:(RNWaterFlowView *)flowView{
    return 2;
}
- (RNWaterFlowCell *)flowView:(RNWaterFlowView *)flowView cellForIndex:(NSUInteger)index{
    static NSString *identifier = @"cell";
    RNWaterFlowCell *cell = [flowView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[RNWaterFlowCell alloc] initWithIdentifier:identifier] autorelease];
    }
    cell.index = index;

    NSString *imgMainUrl = [self.photoListModel photoItemForIndex:index].imgMain;
    NSString *imgHeadUrl = [self.photoListModel photoItemForIndex:index].imgHead;

    if([RNFileCacheManager isCachedFileWithFileName:imgMainUrl])
	{
        UIImage *image = [UIImage imageWithData:[RNFileCacheManager dataWithFileName:imgMainUrl]];
        cell.imageView.image = [self.photoListModel photoItemForIndex:index].imgLargeHeight <= 0 ? [RLUtility getCentralSquareImage:image Length:flowView.cellWidth] : image;
    }else if([RNFileCacheManager isCachedFileWithFileName:imgHeadUrl]){
        UIImage *image = [UIImage imageWithData:[RNFileCacheManager dataWithFileName:imgHeadUrl]];
        cell.imageView.image = [self.photoListModel photoItemForIndex:index].imgLargeHeight <= 0 ? [RLUtility getCentralSquareImage:image Length:flowView.cellWidth] : image;
    }else {
        cell.imageView.image = nil;
        if(flowView.dragging == NO && flowView.decelerating == NO){
            [self requestImageData:cell];
        }
    }
    cell.lableIndex.text =[NSString stringWithFormat:@"%d_%f",index];

    return cell;
}
- (void)flowView:(RNWaterFlowView *)flowView didSelectCellAtIndex:(NSUInteger)index{
    RNWaterFlowCell *cell = [flowView cellForIndex:index];
    
    CGFloat y = cell.origin.y - flowView.contentOffset.y + flowView.origin.y;
    CGFloat x = cell.origin.x;
    

    UIImageView *imageView = (UIImageView *)[_fullScreenView viewWithTag:9999];
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.tag = 9999;
        [_fullScreenView addSubview:imageView];
        [imageView release];
    }
    imageView.image = cell.imageView.image;
    _fullScreenView.backgroundColor = [UIColor blackColor];
    
    _fullScreenView.frame = CGRectMake(x, y, cell.width, cell.height);
    CGFloat sHeight = (_fullScreenView.width * imageView.image.size.height)/imageView.image.size.width;
    imageView.frame = CGRectMake(0, (cell.height - sHeight)/2, cell.width, sHeight);
    _fullScreenView.hidden = NO;
    
    [_miniPublisherView pullViewDown];
    [UIView animateWithDuration:.3 
                     animations:^{
                        CGFloat height = (320 * imageView.image.size.height)/imageView.image.size.width;
                         _fullScreenView.frame = CGRectMake(0, -20, 320, 480);
                         _fullScreenView.contentSize = CGSizeMake(320, height > 480 ? height : 480);
                         if (height>480) {
                             imageView.frame = CGRectMake(0, 0, 320, height);
                         }else {
                             imageView.frame = CGRectMake(0, (480 - height)/2, 320, height);
                         }
                         //OK 不要在该方法中多次调用 .frame 进行更改，造成了混乱
                         self.navBar.frame = CGRectMake(0, -(20 + CONTENT_NAVIGATIONBAR_HEIGHT), 320, CONTENT_NAVIGATIONBAR_HEIGHT);
                         _miniPublisherView.frame = CGRectMake(0, 460, 320, 48);
                     } 
                     completion:^(BOOL finished) {
                        if (finished) {

                             _invokeIndex = index;
                             RNPhotoViewController *photoViewController = [[RNPhotoViewController alloc] 
                                                                         initWithPhotoesData:[self photoListModel]
                                                                                        withAlbum:_albumInfo
                                                                                    withPhotoIndex:index] ;

                            UINavigationController *navigationController = [[UINavigationController alloc] 
                                                                           initWithRootViewController:photoViewController];
						
							navigationController.navigationBarHidden = YES;
							AppDelegate *appDelegate = (AppDelegate *)[UIApplication 
                                                                            sharedApplication].delegate;
                            [appDelegate.mainViewController presentModalViewController:navigationController animated:NO];

							TT_RELEASE_SAFELY(photoViewController);
							TT_RELEASE_SAFELY(navigationController);
                        }
                     }];
   [UIView commitAnimations];
    
}

- (CGFloat)flowView:(RNWaterFlowView *)flowView cellWHRateAtIndex:(NSUInteger)index{
    if ([self.photoListModel photoItemForIndex:index].imgLargeHeight <= 0) {
        return  kDefaultWH;
    }
    return [self.photoListModel photoItemForIndex:index].imgLargeWidth /
    [self.photoListModel photoItemForIndex:index].imgLargeHeight;
}
- (void)touchesBegan:(RNWaterFlowView *)flowView{
    if (_miniPublisherView) {
        [_miniPublisherView pullViewDown];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self performSelectorOnMainThread:@selector(loadImagesForVisibleCell) withObject:nil waitUntilDone:NO];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_miniPublisherView pullViewDown];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self performSelectorOnMainThread:@selector(loadImagesForVisibleCell) withObject:nil waitUntilDone:NO];
    }
    // 末页，不加载
    if (scrollView.contentOffset.y>=0 && self.photoListModel.currentPageIdx >= self.photoListModel.totalPage) {
		[_nextPageFooterView setState:EGOOPullLastPage];
		return;
	}
    // 不是末页，加载
    if((scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height +kBufferHeight)
	   && [_nextPageFooterView state] == EGOOPullNextPagePulling)
	{
        [self load:YES];
		[_nextPageFooterView setState:EGOOPullNextPageLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		_flowView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
		[UIView commitAnimations];
		return;
	}
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //是末页,向上拉
	if (scrollView.isDragging && scrollView.contentOffset.y>=0 
            && self.photoListModel.currentPageIdx >=  self.photoListModel.totalPage) {
		[_nextPageFooterView setState:EGOOPullLastPage];
		return;
	}
	//不是末页 向上拉
	if (scrollView.isDragging && [_nextPageFooterView state]!= EGOOPullNextPageLoading) {
		float offset = scrollView.contentSize.height <= scrollView.frame.size.height
			? scrollView.contentOffset.y 
			: scrollView.contentOffset.y - (scrollView.contentSize.height-scrollView.frame.size.height);
		[_nextPageFooterView setState:offset >= kBufferHeight ? EGOOPullNextPagePulling : EGOOPullNextPageNormal];
	}
}
#pragma mark Image Lazy Load
//加载可视区域的cell image
- (void)loadImagesForVisibleCell
{
     NSMutableArray *arrIndex = [_flowView visibleCellsIndex];
     for (int idx = 0; idx < [arrIndex count]; idx++) {
         @autoreleasepool {
             NSUInteger index = [[arrIndex objectAtIndex:idx] intValue];
             RNWaterFlowCell *cell = [_flowView cellForIndex:index];
             if (cell) {
                 NSString *urlString = [self suitableImageUrl:[self.photoListModel photoItemForIndex:index]];
                 if(![RNFileCacheManager isCachedFileWithFileName:urlString])
                 {
                     [self requestImageData:cell];
                 }
             }
         }
     }
}

#pragma self Private
- (void)requestImageData:(RNWaterFlowCell *)cell{
    NSInteger cellIndex = cell.index;
    NSString *urlString = [self.photoListModel photoItemForIndex:cellIndex].imgMain;
    MKNetworkOperation *op = [_networkEngine operationWithURLString:urlString];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSData *data = [completedOperation responseData];
        [RNFileCacheManager cacheFileWithData:data withFileName:urlString];
        // 图片下载成功后，当前cell可能被重用了
        if (cellIndex != cell.index) {
            return;
        }
        CATransition *animation = [CATransition animation];
        animation.duration = .4;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = kCATransitionFade;
        [[cell layer] addAnimation:animation forKey:@"animation"];
        
        UIImage *image = [UIImage imageWithData:data];
        cell.imageView.image = cell.width / cell.height == kDefaultWH ?
                                [RLUtility getCentralSquareImage:image Length:cell.width] : image;
    } onError:^(NSError *error) {
    }];
    [_networkEngine enqueueOperation:op];
    
}

- (NSString *)suitableImageUrl:(RNPhotoItem *)item{
    if (_networkStatus == ReachableViaWiFi) {
        return  item.imgMain;
    }
    return item.imgHead;
}
- (void)reloadFlowViewData{
    if (_flowView) {
        [_flowView reloadData];
    }
}
- (void)scrollToFlowViewAtIndex:(NSInteger)index{
    if (_flowView) {
        _invokeIndex = index;
        [_flowView scrollToCellAtIndex:index animated:YES];
    }
}
#pragma RNModelController
- (void)createModel {
    RNPhotoListModel *model = [[RNPhotoListModel alloc] initWithAid:self.albumId  withUid:self.userId];
    self.model = model;
    RL_RELEASE_SAFELY(model);
}
- (RNPhotoListModel *)photoListModel{
    return (RNPhotoListModel *)self.model;
}
#pragma mark - upload photo success
- (void)uploadPhotoSuccess:(NSNotification *)notification{
    RN_DEBUG_LOG;
    NSString *aid = [notification object];
    //重新加载数据
    if (aid) {
        if ([aid longLongValue] == [_albumInfo.aid longLongValue]) {
            [self load:NO];
        }
    }else {
        if (AlbumTypePhone == _albumInfo.albumType) {
            [self load:NO];
        }
    }
}
#pragma mark - upload photo
- (void)pickPhotoFinished:(UIImage *)imagePicked photoInfoDic: (NSDictionary * )photoInfoDic{
    //上传照片
    NSMutableDictionary *pram = [NSMutableDictionary dictionaryWithDictionary:photoInfoDic];
    [pram setObject:imagePicked forKey:@"publisherimage"];
    
#warning 由于导航现在实现的暂不能满足a-b-c-a;这种状态暂时这样实现。以后一定需要改掉！！！add by 孙玉平
    [self performSelector:@selector(showphotoPage:) withObject:pram afterDelay:0.8f];    
}
-(void)showphotoPage:(NSMutableDictionary*)pram{
//    
//    RNPublisherViewController *publish=[[RNPublisherViewController alloc] initWithInfo:pram];
//    publish.publishType = EPublishPhotoType;
//    RSAppDelegate *appDelegate = (RSAppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate pushModelViewController:publish];
//    [publish release];
}

#pragma right button and actionsheet
//上传照片
- (void)uploadPhoto:(id)sender{
    [_miniPublisherView pullViewDown];
    RN_DEBUG_LOG;
    
    RNUIActionSheet *actionSheet = [[RNUIActionSheet alloc] initWithTitle:nil];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"相册选择", @"相册选择") withBlock:^(NSInteger index) {
        //从相册选择//不能立即释放，内部逻辑需要
        if (_iphotocon == nil) {
            _iphotocon = [[RNPickPhotoHelper alloc] initWithAlbumId:(NSString *)_albumInfo.aid withAlbumName:_albumInfo.title];
        }
        _iphotocon.delegate = self;
        [_iphotocon pickPhotoWithSoureType:UIImagePickerControllerSourceTypePhotoLibrary];

    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"立刻拍照", @"立刻拍照") withBlock:^(NSInteger index) {
        //从相机拍照//不能立即释放，内部逻辑需要
        if (_iphotocon == nil) {
            _iphotocon = [[RNPickPhotoHelper alloc] initWithAlbumId:(NSString *)_albumInfo.aid withAlbumName:_albumInfo.title];
        }
        _iphotocon.delegate = self;
        [_iphotocon pickPhotoWithSoureType:UIImagePickerControllerSourceTypeCamera];

    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"取消", @"取消") withBlock:^(NSInteger index) {
    }];
    actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
    [actionSheet release];
}
//分享相册
- (void)shareAlbum:(id)sender{
//    [_miniPublisherView pullViewDown];
//    
//    if(_albumInfo.visible != AlbumVisibleAll || _albumInfo.hasPassword){ 
//        [self showSimpleHUD:NSLocalizedString(@"用户设置的权限不能分享", @"用户设置的权限不能分享")];
//        return;
//    }
//    
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:_shareId ? _shareId :_albumInfo.aid forKey:@"id"];
//    [dict setObject:_shareUid ? _shareUid : _albumInfo.uid forKey:@"uid"];
//    [dict setObject:[NSNumber numberWithInt:RRShareTypeAlbum] forKey:@"source_type"];
//    [dict setObject:[NSNumber numberWithInt:0] forKey:@"type"];
//    RNPublisherViewController *publish=[[RNPublisherViewController alloc] initWithInfo:dict];
//    publish.publishType = EPublishShareType;
//    RSAppDelegate *appDelegate = (RSAppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate pushModelViewController:publish];
//    [publish release];
//    
}
//收藏相册
- (void)favAlbum:(id)sender{
//    if(_albumInfo.visible != AlbumVisibleAll || _albumInfo.hasPassword){ 
//        [self showSimpleHUD:NSLocalizedString(@"用户设置的权限不能分享", @"用户设置的权限不能分享")];
//        return;
//    }
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:_shareId ? _shareId :_albumInfo.aid forKey:@"id"];
//    [dict setObject:_shareUid ? _shareUid : _albumInfo.uid forKey:@"uid"];
//    [dict setObject:[NSNumber numberWithInt:RRShareTypeAlbum] forKey:@"source_type"];
//    [dict setObject:[NSNumber numberWithInt:1] forKey:@"type"];
//    RNPublisherViewController *publish=[[RNPublisherViewController alloc] initWithInfo:dict];
//    publish.publishType = EPublishShareType;
//    RSAppDelegate *appDelegate = (RSAppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate pushModelViewController:publish];
//    [publish release];
}
//查看原作者
- (void)lookupAuthor:(id)sender{
//    RN_DEBUG_LOG;
//    RCUser *rcUser = [[RCUser alloc] initWithUserId:_albumInfo.uid];
//    RNUserHomeViewController *uhvc = [[RNUserHomeViewController alloc] initWithUserInfo:rcUser];
//    [self.navigationController pushViewController:uhvc animated:YES];
//    [rcUser release];
//    [uhvc release];
}
- (void)showMore:(id)sender{
    [_miniPublisherView pullViewDown];
    RNUIActionSheet *actionSheet = [[RNUIActionSheet alloc] initWithTitle:NSLocalizedString(@"更多操作", @"更多操作")];
    if ([_mainUser.userId longLongValue] == [_albumInfo.aid longLongValue]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"分享相册", @"分享相册")withBlock:^(NSInteger index) {
            [self shareAlbum:nil];
        }];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"收藏相册", @"收藏相册") withBlock:^(NSInteger index) {
        [self favAlbum:nil];
    }];
    if (AlbumStartSourceShare == _startSource) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"查看源作者", @"查看源作者") withBlock:^(NSInteger index) {
            [self lookupAuthor:nil];
        }];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"取消", @"取消") withBlock:^(NSInteger index) {
    }];
    actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
    [actionSheet release];
}
- (void)loadRightButtons{
    if ([_mainUser.userId longLongValue] == [_albumInfo.uid longLongValue]) {
        //1)	自己的头像相册右上角只有上传照片按钮，点击上传时在编辑界面默认上传到头像相册，不可更改；
        //2)	头像相册不可分享、收藏；
        //自己的相册：上传照片按钮（编辑界面上传相册默认本相册且不可改）+更多操作按钮[分享相册、收藏相册、取消]
        [self.navBar addExtendButtonWithTarget:self
                         touchUpInSideSelector:@selector(uploadPhoto:)
                                   normalImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_camera"] 
                              highlightedImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_camera"]];
        
        
        if (_albumInfo.albumType != AlbumTypeHead) {
            [self.navBar addExtendButtonWithTarget:self
                             touchUpInSideSelector:@selector(showMore:)
                                       normalImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_more"] 
                                  highlightedImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_more"]];
        }
    }else {
        //非自己的相册：分享相册+更多操作按钮[收藏相册、查看源作者（分享的相册有此项）、取消]
        [self.navBar addExtendButtonWithTarget:self
                             touchUpInSideSelector:@selector(shareAlbum:)
                                       normalImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_share"]
                                  highlightedImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_share"]];
        
        [self.navBar addExtendButtonWithTarget:self
                         touchUpInSideSelector:@selector(showMore:)
                                   normalImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_more"] 
                              highlightedImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_more"]];
    }
    
    //显示底部评论
    _miniPublisherView = [[RNMiniPublisherView alloc] initWithFrame:CGRectMake(0, 460 - 48, 320, 48) 
                                                     andCommentType:ECommentAlbumType];
    _miniPublisherView.miniPublisherDelegate = self;
    _miniPublisherView.parentControl = self;
    [self.view addSubview:_miniPublisherView];
    [_miniPublisherView resetQuery:[NSDictionary 
                                    dictionaryWithObjects:
                                    [NSArray arrayWithObjects:_albumInfo.aid,_albumInfo.uid,nil] 
                                    forKeys:[NSArray arrayWithObjects:@"aid",@"uid", nil]]
                   andCommentCount:_albumInfo.commentCount];
    _miniPublisherView.bIsShowCommentCount = YES;
    //导航标题
    self.navBar.title = _albumInfo.title;
	
}

/*
	退出照片相册内容页
 */
- (void)backButtonAction{
	[self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - HUD
- (void)showSimpleHUD:(NSString *)tip{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tip;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1.3];
}

#pragma request album info
- (void)requestAlbumInfo{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSMutableDictionary* dics = [NSMutableDictionary dictionary];
        [dics setObject:_mainUser.sessionKey forKey:@"session_key"];
        [dics setObject:_albumId forKey:@"aid"];
        [dics setObject:_userId forKey:@"uid"];
        NSString *password = _tInputPassword.text;
        if(password){
            [dics setObject:password forKey:@"password"];
        }
//        __block typeof(self) self = self;
        RCGeneralRequestAssistant *mReqAssistant = [RCGeneralRequestAssistant requestAssistant];
        mReqAssistant.onCompletion = ^(NSDictionary* result){
            if (result) {
                _albumInfo = [[RNAlbumItem alloc] initWithDictionary:result];
                //右侧按钮
                [self loadRightButtons];
            }
        };
        mReqAssistant.onError = ^(RCError* error) {
            NSLog(@"error....%@",error.titleForError);
        };
        [mReqAssistant sendQuery:dics withMethod:@"photos/getAlbums"];
    [pool release];
}
#pragma mark - RNModelDelegate
// 开始
- (void)modelDidStartLoad:(RNPhotoListModel *)model {
    // 子类实现
    [self showDataIndicator];
}

// 完成
- (void)modelDidFinishLoad:(RNPhotoListModel *)model {
    // 子类实现
    UIView *view = [self.view viewWithTag:kTagActivity];
    if (view) {
        [view removeFromSuperview];
    }
    [_flowView reloadData];
    
    _nextPageFooterView.hidden = NO;
	_nextPageFooterView.frame = CGRectMake(0,  MAX(_flowView.contentSize.height, _flowView.height)
                                           , _flowView.contentSize.width, 200);
	[_nextPageFooterView setState:EGOOPullNextPageNormal];
	_flowView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

// 错误处理
- (void)model:(RNPhotoListModel *)model didFailLoadWithError:(RCError *)error {
    UIView *view = [self.view viewWithTag:kTagActivity];
    if (view) {
        [view removeFromSuperview];
    }
    // 子类实现
    if(RRErrorCodeEcPasswordError == error.code){
        //        20003 	密码错误
        _wrongPwdTimes ++ ;
        [self showAlertForPwd];
    }else if(RRErrorCodePhotoNeedPassword  == error.code){
        //        20105 	加密相册，请输入密码
        [self showAlertForPwd];
	}else {
        //        200 	用户无权限 20001 	资源不存在  20006 	黑名单限制  20107 	照片未知错误 
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:error.titleForError
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"确定", @"确定")  
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

// 取消
- (void)modelDidCancelLoad:(RNPhotoListModel *)model {
    // 子类实现
}

#pragma UIAlertView
- (void) showAlertForPwd {
	if(_tAlert){
		RL_RELEASE_SAFELY(_tAlert)
	}
	if(self.tAlert == nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
														message:NSLocalizedString(@"相册密码\n ", @"相册密码\n ") 
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"确定", @"确定") , NSLocalizedString(@"取消", @"取消"), nil];
        
        if (_wrongPwdTimes > 0) {
            alert.message = NSLocalizedString(@"密码错误，请重新输入密码\n ", @"密码错误，请重新输入密码\n ");
        }
		self.tAlert = alert;
		[alert release];
		
		self.tAlert.cancelButtonIndex = 1;
		
		UITextField *tempTF = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 28)];
		self.tInputPassword = tempTF;
		[tempTF release];
		
        self.tInputPassword.delegate = self;
		self.tInputPassword.placeholder = NSLocalizedString(@"请输入密码", @"请输入密码");
		self.tInputPassword.secureTextEntry = YES;
		self.tInputPassword.borderStyle = UITextBorderStyleRoundedRect;
		self.tInputPassword.returnKeyType = UIReturnKeyDone;
		[self.tInputPassword addTarget:self 
								action:@selector(doneClicked:) 
					  forControlEvents:UIControlEventEditingDidEndOnExit];
		[self.tAlert addSubview:_tInputPassword];
	}
	[self.tAlert show];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 密码不能超过16个字符。
    if(range.location >= PASSWORD_TEXT_LENGTH)
        return NO;
    else
        return YES;
}

- (void)doneClicked:(id)sender
{
	[sender resignFirstResponder];
}
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 0 && alertView == self.tAlert)
	{
		NSString *password = _tInputPassword.text;
		if(password){
			[self.model.query setObject:password forKey:@"password"];
            [self requestAlbumInfo];
            [self load:NO];
		}else {
            [self showAlertForPwd];
        }
	}else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)showDataIndicator{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.tag = kTagActivity;
    activityIndicatorView.center = CGPointMake(320/2, 460/2);
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView release];
    [activityIndicatorView startAnimating];
    [self.view bringSubviewToFront:activityIndicatorView];
}
#warning 此处是进入评论列表
#pragma mark - RNMiniPublisherDelegate
- (void)onClickCommentCountButton{
//    if (_albumInfo) {
//        NSString *url = [NSString stringWithFormat:@"http://%@/album/%@/%@/comments?no_feed=1",
//                         [HummerSettings shareInstance].host,
//                         [_albumInfo.uid stringValue],
//                         [_albumInfo.aid stringValue]];
//        viewController = [[RNFeedCommentViewController alloc] initWithUrlString:url];
//        [self.navigationController pushViewController:viewController animated:NO];
//        [UIView transitionFromView:self.view
//                            toView:viewController.view
//                          duration:0.5 
//                           options:(UIViewAnimationOptionTransitionFlipFromRight)
//                        completion:^(BOOL finished) {
//                            
//                        }];
//        [viewController.navBar.backButton removeTarget:self.navigationController 
//                                                action:@selector(popViewControllerWithAnimate) forControlEvents:UIControlEventTouchUpInside];
//        [viewController.navBar.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//        [viewController release];
//    }
    
}

- (void)back:(id)sender{
//    [UIView transitionFromView:viewController.view
//                        toView:self.view
//                      duration:0.5 
//                       options:(UIViewAnimationOptionTransitionFlipFromLeft)
//                    completion:^(BOOL finished) {
//                        
//                    }];
//    [viewController.navigationController popViewControllerAnimated:NO];
}
- (void)pullDownFinished{
    
}

- (void)textViewShouldBeginEditing{
    
}
@end
