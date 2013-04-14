//
//  PhotoViewController.m
//  RRSpring
//
//  Created by sheng siglea on 3/21/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RNPhotoViewController.h"
#import "RCMainUser.h"
#import "RNUIActionSheet.h"
#import "RNMainViewController.h"
//#import "RNUserHomeViewController.h"

#define kTagPhotoBase 8000
#define kTagActivity 2000
#define kPublisherViewHeight 48
#define PASSWORD_TEXT_LENGTH 16
#define kTagHUD 9000
@interface RNPhotoViewController ()

@property(nonatomic,retain) RNPhotoListModel *model;
@property (nonatomic, retain) UIAlertView *tAlert;
@property (nonatomic, retain) UITextField *tInputPassword;

//给定索引对应的照片
- (RNScrollImageView *)photoImageViewForIndex:(NSUInteger)index;
//获取可重用的照片对象
- (RNScrollImageView *)dequeueReusablePhotoImageView;
//把不使用照片加入重用队列
- (void)addPhotoImageViewToReuseQueue:(RNScrollImageView *)photoView;
//准备当前照片的上下照片
- (void)preparePreNextPhotoImage;
//移除不在可视区域的照片
- (void)removePhotoImageOutofVisibleView;
//屏幕旋转等操作，重新布局
- (void)adjustSubviews;
//显示当前照片的大图
- (void)displayCurrentLargePhoto;
//显示下载进度圆圈指示 
- (MBProgressHUD *)showHUDIndicator:(NSInteger)index;
//如果由相册内容页进入照片内容页，滚动照片时，使照片列表滚动
- (void)scrollAlbumController;
//显示数据加载时指示
- (void)showDataIndicator;
//获取照片信息，从单张照片进入
- (void)requestPhotoInfo;
//调整底部View
- (void)adjustBottomView;
//展示密码输入框
- (void)showAlertForPwd;
//展示错误提示框
- (void)showAlertForError:(RCError *)error;
//查看相册
- (void)lookupAlbum;
//收藏照片
- (void)favPhoto;
//查看照片地点
- (void)lookupPhotoLbs;
//删除照片
- (void)deletePhoto;
//查看原作者
- (void)lookupAuthor; 
//分享照片
- (void)sharePhoto;
//设置用户头像 
- (void)resetUserHead;
//当前照片信息
- (RNPhotoItem *)currentPhotoItem;
// wifi 使用200 W 图，3G使用 100 W 图
- (NSString *)suitableImageUrl:(RNPhotoItem *)item;
// 小图／中图／大图 都可能被缓存
- (NSString *)suitableImageCachedUrl:(RNPhotoItem *)item;
// 显示简单提示
- (void)showSimpleHUD:(NSString *)tip;
@end

@implementation RNPhotoViewController

@synthesize model = _model;
@synthesize tAlert = _tAlert;
@synthesize tInputPassword = _tInputPassword;

- (id)init{
    if (self = [super init]) {
        self.wantsFullScreenLayout = YES;
        _networkEngine = [[MKNetworkEngine alloc] init];
        [_networkEngine useCache];
        isKeepIndex = NO;
        _currentPhotoIndex = 0;
        _mainUser = [RCMainUser getInstance];
        _dataLoadStatus = DataLoadStatusReady;
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(reachabilityChanged:) 
                                                     name:kReachabilityChangedNotification 
                                                   object:nil];
        Reachability *r = [Reachability reachabilityWithHostname:@"www.renren.com"];
        [r startNotifier];
        _networkStatus = [r currentReachabilityStatus];
    }
    return self;
}
- (id)initWithUid:(NSString *)uid withPid:(NSString *)pid  shareId:(NSString *)sid shareUid:(NSString *)suid{
    if (self = [self init]) {
        _userId = [(NSNumber *)uid copy];
        _photoId = [(NSNumber *)pid copy];
        _shareId = [(NSNumber *)sid copy];
        _shareUid = [(NSNumber *)suid copy];
        _startSource = PhotoStartSourceShare;
    }
    return self;
}
- (id)initWithPhotoesData:(RNPhotoListModel *)pmodel withAlbum:(RNAlbumItem *)albumItem withPhotoIndex:(NSInteger)index{
    self = [self init];
    if (self) {
        _currentPhotoIndex = index;
        _albumInfo = [albumItem retain];
        _dataLoadStatus = DataLoadStatusAlbumFirstFinished;
        _startSource = PhotoStartSourceAlbum;
        self.model = pmodel;
        [self.model.delegates addObject:self];
		NSLog(@"photoViewController self retainCount = %d",[self retainCount]);
    }
    return self;
}
//- (id)initWithURLAction:(HummerURLAction *)action{
//    NSDictionary *dics = action.pathParseResult;
//    if(dics){
//        if([dics count]>=2){
//            NSString *ownerId = [dics objectForKey:@"ownerId"];
//            NSString *pid = [dics objectForKey:@"photoId"];
//            NSString *sourceId = [dics objectForKey:@"sourceId"];
//            NSString *shareId = [dics objectForKey:@"shareId"];
//            NSString *sourceUserId = [dics objectForKey:@"sourceUserId"];
//            if(shareId){
//                self = [self initWithUid:sourceUserId withPid:sourceId shareId:shareId shareUid:ownerId];
//            }else{
//                self = [self initWithUid:ownerId withPid:pid shareId:nil shareUid:nil];
//            }
//            return self;
//        }
//    }
//    return nil;
//
//}
- (void)loadView{
    [super loadView];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    [UIApplication sharedApplication].statusBarHidden = _startSource == PhotoStartSourceAlbum ;
    self.view.backgroundColor = [UIColor blackColor];

    _photosScrollView = [[UIScrollView alloc] init];
    _photosScrollView.pagingEnabled = YES;
    _photosScrollView.showsVerticalScrollIndicator = NO;
    _photosScrollView.showsHorizontalScrollIndicator = NO;
    _photosScrollView.delegate = self;
    [self.view addSubview:_photosScrollView];
        
    _narBarView = [[UIView alloc] init];
    if (_startSource == PhotoStartSourceShare) {
        // 从分享页面进入 显示导航
        _narBarView.frame = CGRectMake(0, 20, _rWidth, 44);
    }

    _narBarView.backgroundColor = [UIColor colorWithPatternImage:[[RCResManager getInstance] imageForKey:@"photo_narbar_bg"]];
    [self.view addSubview:_narBarView];
    
    _narBarBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 45, 44)];
    [_narBarBackBtn setBackgroundImage:[[RCResManager getInstance] imageForKey:@"photo_narbar_back"] forState:UIControlStateNormal];
    [_narBarBackBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_narBarView addSubview:_narBarBackBtn];
    
    _narBarTitleLabel = [[UILabel alloc] init];
    _narBarTitleLabel.textColor = [UIColor whiteColor];
    _narBarTitleLabel.backgroundColor = [UIColor clearColor];

    _narBarTitleLabel.font = [UIFont boldSystemFontOfSize:20];  
    _narBarTitleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    _narBarTitleLabel.shadowOffset = CGSizeMake(0, -1);
    _narBarTitleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _narBarTitleLabel.textAlignment = UITextAlignmentLeft;
    [_narBarView addSubview:_narBarTitleLabel];
    
    _narBarFirstBtn = [[UIButton alloc] init];
    [_narBarView addSubview:_narBarFirstBtn];
    [_narBarFirstBtn setBackgroundImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_share"] forState:UIControlStateNormal];
    [_narBarFirstBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _narBarDownBtn = [[UIButton alloc] init];
    [_narBarDownBtn setBackgroundImage:[[RCResManager getInstance] imageForKey:@"photo_narbar_down"] forState:UIControlStateNormal];
    [_narBarDownBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_narBarView addSubview:_narBarDownBtn];
    
    _navBarMoreBtn = [[UIButton alloc] init];
    [_navBarMoreBtn setBackgroundImage:[[RCResManager getInstance] imageForKey:@"navigationbar_btn_more"] forState:UIControlStateNormal];
    [_navBarMoreBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];    
    [_narBarView addSubview:_navBarMoreBtn];
    
    _quickBgView = [[UIView alloc] init];
    _quickBgView.backgroundColor = [UIColor colorWithPatternImage:[[RCResManager getInstance] imageForKey:@"photo_quick_bg"]];
    [self.view addSubview:_quickBgView];
    
    UISwipeGestureRecognizer *bgSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)];
    [_quickBgView addGestureRecognizer:bgSwipeGestureRecognizer];
    [bgSwipeGestureRecognizer release];
    
    _quickTableView = [[UITableView alloc] init];
    _quickTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _quickTableView.delegate = self;
    _quickTableView.dataSource = self;
    _quickTableView.backgroundColor = [UIColor clearColor];
    [_quickBgView addSubview:_quickTableView];
    
    _quickButton = [[UIButton alloc] init];
    [_quickButton setBackgroundImage:[[RCResManager getInstance] imageForKey:@"photo_quick_btn"] forState:UIControlStateNormal];
    [_quickButton addTarget:self 
                     action:@selector(changeQuickTableView:) 
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_quickButton];
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)];
    [_quickButton addGestureRecognizer:swipeGestureRecognizer];
    [swipeGestureRecognizer release];
    
    _quickArrImageView = [[UIImageView alloc] init];
    _quickArrImageView.size = CGSizeMake(17, 17);
    _quickArrImageView.image = [[RCResManager getInstance] imageForKey:@"photo_quick_arrow"];
    [self.view addSubview:_quickArrImageView];
    
    _bottomView = [[UIView alloc] init];
    _bottomView.alpha = .8;
    _bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_bottomView];
    
    _photoDescLable = [[UILabel alloc] init];
    _photoDescLable.numberOfLines = 5;
    _photoDescLable.textColor = [UIColor whiteColor];
    _photoDescLable.backgroundColor = [UIColor clearColor];
    _photoDescLable.font = [UIFont systemFontOfSize:14];
    _photoDescLable.lineBreakMode = UILineBreakModeTailTruncation;
    _photoDescLable.textAlignment = UITextAlignmentCenter;
    [_bottomView addSubview:_photoDescLable];
    
    _viewShareCountLable = [[UILabel alloc] init];
    _viewShareCountLable.textColor = [UIColor whiteColor];
    _viewShareCountLable.backgroundColor = [UIColor clearColor];
    _viewShareCountLable.font = [UIFont systemFontOfSize:14];
    _viewShareCountLable.lineBreakMode = UILineBreakModeTailTruncation;
    _viewShareCountLable.textAlignment = UITextAlignmentCenter;
    [_bottomView addSubview:_viewShareCountLable];
    
    _locationImageView = [[UIImageView alloc] init];//25 22
    _locationImageView.image = [[RCResManager getInstance] imageForKey:@"navigationbar_btn_locate"];
    [_bottomView addSubview:_locationImageView];
    
    _locationButton = [[UIButton alloc] init];
    [_locationButton addTarget:self action:@selector(lsbAction:) forControlEvents:UIControlEventTouchUpInside];
    [_locationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _locationButton.backgroundColor = [UIColor clearColor];
    _locationButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _locationButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_bottomView addSubview:_locationButton];
   
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (_dataLoadStatus == DataLoadStatusReady) {
         // 分享单张照片进入 照片内容页面 加载当前照片信息
         [self requestPhotoInfo];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	//chenyi add 
	[self.navigationController setNavigationBarHidden:YES animated:YES];
    if (_miniPublisherView) {
        [_miniPublisherView pullViewDown];
    }
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    if(_dataLoadStatus == DataLoadStatusAlbumFirstFinished){
//        // 从用户自己的相册进入，为支持删除动作，获取该相册所有照片数据
//        if ([_mainUser.userId longLongValue] == [_albumInfo.uid longLongValue]) {
//            // 加载所有照片信息
//            if ([self.model.items count] < self.model.totalItem) {
//                [self.model.query setObject:[NSNumber numberWithInt:1] forKey:@"all"];
//                [self.model load:NO];
//            }
//        }
//    }
}
- (void)viewDidUnload
{
    [_locationButton release];
    [_locationImageView release];
    [_viewShareCountLable release];
    [_photoDescLable release];
    [_bottomView release];
    [_quickArrImageView release];
    [_quickButton release];
    [_quickTableView release];
    [_quickBgView release];
    [_navBarMoreBtn release];
    [_narBarDownBtn release];
    [_narBarFirstBtn release];
    [_narBarTitleLabel release];
    [_narBarBackBtn release];
    [_narBarView release];
    [_photosScrollView release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (void)dealloc{
    RN_DEBUG_LOG;
	if (_arrReusePhotoImageViews) {
		[_arrReusePhotoImageViews release];
	}
    [_networkEngine release];
    [self.model.delegates removeObject:self];
    self.model = nil;
    [_userId release];
    [_photoId release];
    [_albumInfo release];
    self.tInputPassword = nil;
    self.tAlert = nil;
	
	[_locationButton release];
    [_locationImageView release];
    [_viewShareCountLable release];
    [_photoDescLable release];
    [_bottomView release];
    [_quickArrImageView release];
    [_quickButton release];
    [_quickTableView release];
    [_quickBgView release];
    [_navBarMoreBtn release];
    [_narBarDownBtn release];
    [_narBarFirstBtn release];
    [_narBarTitleLabel release];
    [_narBarBackBtn release];
    [_narBarView release];
    [_photosScrollView release];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}
- (void)swipe{
    RN_DEBUG_LOG;
    [self changeQuickTableView:nil];

}
- (void)changeQuickTableView:(id)sender{
    if (_dataLoadStatus != DataLoadStatusAlbumFirstFinished) {
        return;
    }
    [UIView animateWithDuration:.3 
                          delay:0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         if ((int)_quickButton.left == (int)(_rWidth - 31)) {
                             if (sender) {
                                 [_quickTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentPhotoIndex inSection:0]
                                                        atScrollPosition:UITableViewScrollPositionMiddle 
                                                                animated:NO];
                                 
                                 _quickButton.frame = CGRectMake(_rWidth - 31 - 125 + 6, (_rHeight - 85)/2, 31, 85);
                                 _quickArrImageView.center = CGPointMake(_quickButton.center.x + 6.5, _quickButton.center.y);
                                 _quickArrImageView.transform = CGAffineTransformMakeRotation(-M_PI);
                                 _quickBgView.frame = CGRectMake(_rWidth - 125, 20, 125, _rHeight - 20);
                                 _quickTableView.frame = CGRectMake(13, 1, 105, _quickBgView.height - 1);
                                 
                                 _narBarView.frame = CGRectMake(0, -44, _rWidth, 44);
                                 _bottomView.frame = CGRectMake(0, _rHeight, _rWidth, _bottomView.height);
                                 _miniPublisherView.frame = CGRectMake(0,_rHeight, _rWidth, kPublisherViewHeight);
                                 [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                                         withAnimation:UIStatusBarAnimationFade|UIStatusBarAnimationSlide];
                             }
                         }else {
                                 _quickButton.frame = CGRectMake(_rWidth, (_rHeight - 85)/2, 31, 85);
                                 _quickArrImageView.center = CGPointMake(_quickButton.center.x + 6.5, _quickButton.center.y);
                                 _quickArrImageView.transform = CGAffineTransformIdentity;
                                 _quickBgView.frame = CGRectMake(_rWidth, 20, 125, _rHeight - 20);
                                 _quickTableView.frame = CGRectMake(13, 1, 105, _quickBgView.height - 1);
                                 [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                                         withAnimation:UIStatusBarAnimationFade|UIStatusBarAnimationSlide];
                         }
                         
                     } completion:^(BOOL finished) {
                         // 快速浏览图片更新
                         [self performSelectorOnMainThread:@selector(loadImagesForOnscreenRows) withObject:nil waitUntilDone:NO];
                     }];
   

}

- (void)adjustSubviews{
    
    //不依赖数据布局
    if (![UIApplication sharedApplication].isStatusBarHidden) {
        if ((int)_narBarView.top == 20) {
            _narBarView.hidden = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
            _narBarView.frame = CGRectMake(0, 20, _rWidth, 44);
            _quickButton.frame = CGRectMake(_rWidth - 31, (_rHeight - 85)/2, 31, 85);
            _quickArrImageView.center =  CGPointMake(_quickButton.center.x + 6.5, _quickButton.center.y);
            _quickBgView.frame = CGRectMake(_rWidth, 20, 125, _rHeight - 20);
            _quickTableView.frame = CGRectMake(13, 1, 105, _quickBgView.height - 1);
        }else {
            _narBarView.frame = CGRectMake(0, -44, _rWidth, 44);
            _quickButton.frame = CGRectMake(_rWidth - 31 - 125 + 6, (_rHeight - 85)/2, 31, 85);
            _quickArrImageView.center =  CGPointMake(_quickButton.center.x + 6.5, _quickButton.center.y);
            _quickBgView.frame = CGRectMake(_rWidth - 125, 20, 125, _rHeight - 20);
            _quickTableView.frame = CGRectMake(13, 1, 105, _quickBgView.height - 1);
        }
    }else {
        _narBarView.frame = CGRectMake(0, -44, _rWidth, 44);
        _quickButton.frame = CGRectMake(_rWidth, (_rHeight - 85)/2, 31, 85);
         _quickArrImageView.center =  CGPointMake(_quickButton.center.x + 6.5, _quickButton.center.y);
        _quickBgView.frame = CGRectMake(_rWidth, 20, 125, _rHeight - 20);
        _quickTableView.frame = CGRectMake(13, 1, 105, _quickBgView.height - 1);
    }
    _narBarTitleLabel.frame = CGRectMake(5 + _narBarBackBtn.left + _narBarBackBtn.width + 5,
                                         0, _rWidth - 131 - _narBarBackBtn.width -15, _narBarView.height);
    _narBarDownBtn.frame = CGRectMake(_rWidth - 131, 4, 34, 35);
    _narBarFirstBtn.frame = CGRectMake(_rWidth - 131 + 34 + 12, 4, 34, 35);
    _navBarMoreBtn.frame = CGRectMake(_rWidth - 131 + (34 + 12)*2, 4, 34, 35);
    
    UIView *HUD = [self.view viewWithTag:kTagHUD+_currentPhotoIndex];
    if (HUD) {
        HUD.center = CGPointMake(_rWidth/2, _rHeight/2);
    }
    if([self.view viewWithTag:kTagActivity]){
        [self.view viewWithTag:kTagActivity].center = CGPointMake(_rWidth/2, _rHeight/2);
    }
    [self adjustBottomView];
    //依赖数据布局及显示
    //数据未准备好，获取数据
    if (_dataLoadStatus >= DataLoadStatusCurrentPhotoFinished && _dataLoadStatus <= DataLoadStatusAlbumFirstLoading){
        //已经获取当前照片
        isKeepIndex = YES;     
        _photosScrollView.frame = CGRectMake(0, 0, _rWidth, _rHeight);
        _photosScrollView.contentOffset = CGPointMake(0, 0);
        _photosScrollView.contentSize = CGSizeMake(_rWidth, _rHeight);
        isKeepIndex = NO;
        
        _narBarTitleLabel.text = [NSString stringWithFormat:@"1/1"];
        [_photosScrollView addSubview:[self photoImageViewForIndex:0]];
        [self displayCurrentLargePhoto];
    }
    if (_dataLoadStatus == DataLoadStatusAlbumFirstFinished) {
        if (_currentPhotoIndex >= self.model.totalItem) {
            _currentPhotoIndex = 0;
        }
        //在最后一张照片旋转时出现改问题 
        //_photosScrollView.frame != contentsize 时 触发didscrollView
        isKeepIndex = YES;     
        _photosScrollView.frame = CGRectMake(0, 0, _rWidth, _rHeight);
        _photosScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _rWidth, 0);
        _photosScrollView.contentSize = CGSizeMake(_rWidth*self.model.totalItem, _rHeight);
        isKeepIndex = NO;
        
        _narBarTitleLabel.text = [NSString stringWithFormat:@"%d/%d",self.model.totalItem == 0 ? 0 :_currentPhotoIndex + 1,self.model.totalItem];
        
        RNScrollImageView *currentPhotoView = (RNScrollImageView *)[_photosScrollView viewWithTag:
                                                                    kTagPhotoBase + _currentPhotoIndex];
        if (currentPhotoView == nil) {
            currentPhotoView = [self photoImageViewForIndex:_currentPhotoIndex];
            [_photosScrollView addSubview:currentPhotoView];
        }
        [self displayCurrentLargePhoto];
        currentPhotoView.frame = CGRectMake(_currentPhotoIndex * _rWidth, 0, _rWidth, _rHeight);
        [currentPhotoView adjustViews];
        if ([_photosScrollView viewWithTag:(kTagPhotoBase + _currentPhotoIndex - 1)]) {
            RNScrollImageView *prePhotoView = (RNScrollImageView *)[_photosScrollView 
                                                                    viewWithTag:(kTagPhotoBase + _currentPhotoIndex - 1)];
            [self addPhotoImageViewToReuseQueue:prePhotoView];
            [prePhotoView removeFromSuperview];
        }
        if ([_photosScrollView viewWithTag:(kTagPhotoBase + _currentPhotoIndex + 1)]) {
            RNScrollImageView *nextPhotoView = (RNScrollImageView *)[_photosScrollView 
                                                                     viewWithTag:(kTagPhotoBase + _currentPhotoIndex + 1)];
            [self addPhotoImageViewToReuseQueue:nextPhotoView];
            [nextPhotoView removeFromSuperview];
        }
    }
}
- (void)buttonAction:(id)sender{
    if (sender == _narBarBackBtn) {
        [self scrollAlbumController];		
		[self dismissModalViewControllerAnimated:YES];
    }else if(sender == _navBarMoreBtn){
        RNUIActionSheet *actionSheet = [[RNUIActionSheet alloc] initWithTitle:NSLocalizedString(@"更多操作", @"更多操作")];
        if (_startSource == PhotoStartSourceShare) {
            [actionSheet addButtonWithTitle:NSLocalizedString(@"查看相册", @"查看相册") withBlock:^(NSInteger index) {
                [self lookupAlbum];
            }];
        }
        
        RNPhotoItem *item = self.currentPhotoItem;
        if (item) {
                
            [actionSheet addButtonWithTitle:NSLocalizedString(@"收藏照片", @"收藏照片") withBlock:^(NSInteger index) {
                [self favPhoto];
            }]; 
            
            if (item.lbsItem) {
                [actionSheet addButtonWithTitle:NSLocalizedString(@"查看照片地点", @"查看照片地点") withBlock:^(NSInteger index) {
                    [self lookupPhotoLbs];
                }];
            }
            
            if ([_mainUser.userId longLongValue] == [item.userId longLongValue] && 
                ![_mainUser.headurl isEqualToString:item.imgHead]) {
                // 当前用户并且不是当前头像的照片
                [actionSheet addButtonWithTitle:NSLocalizedString(@"删除照片", @"删除照片") withBlock:^(NSInteger index) {
                    [self deletePhoto];
                }];
            }
        }
        if (_startSource == PhotoStartSourceShare && _shareId) {
            [actionSheet addButtonWithTitle:NSLocalizedString(@"查看源作者", @"查看源作者") withBlock:^(NSInteger index) {
                [self lookupAuthor];
            }];
        }
        [actionSheet addButtonWithTitle:NSLocalizedString(@"取消", @"取消") withBlock:^(NSInteger index) {
        }];
        actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1;
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:self.view];
        [actionSheet release];
    }else if(sender == _narBarDownBtn){
        
        NSString *urlString = [self.model photoItemForIndex:_currentPhotoIndex].imgLarge;
        if ([RNFileCacheManager isCachedFileWithFileName:urlString]) {
            UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:[RNFileCacheManager dataWithFileName:urlString]], self, 
                                           @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }else {
            MKNetworkOperation *op = [_networkEngine operationWithURLString:urlString];
            [op onCompletion:^(MKNetworkOperation *completedOperation) {
                NSData *data = [completedOperation responseData];
                UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], self, 
                                               @selector(image:didFinishSavingWithError:contextInfo:), nil);
            } onError:^(NSError *error) {
            }];
            [_networkEngine enqueueOperation:op];
        }
    }else if(sender == _narBarFirstBtn){
        [self sharePhoto];
    }
}
#pragma mark - reachabilityChanged
- (void) reachabilityChanged: (NSNotification* )note
{
    
    Reachability* r = [note object];
    _networkStatus = [r currentReachabilityStatus];
    
}
#pragma mark - save photo to local
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	
    if (error == nil){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
														message:NSLocalizedString(@"成功保存到本地。", @"成功保存到本地。") 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"确定", @"确定") 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
        
	}
    else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
														message:NSLocalizedString(@"磁盘已满，请稍候重试。", @"磁盘已满，请稍候重试。") 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"确定", @"确定") 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	
}
//查看相册
- (void)lookupAlbum{
    RN_DEBUG_LOG;
    [self dismissModalViewControllerAnimated:NO];
    RNAlbumWaterViewController *albumViewController = [[RNAlbumWaterViewController alloc] 
                                                       initWithPhotoesData:self.model withAlbum:_albumInfo];
    albumViewController.hidesBottomBarWhenPushed = YES;
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication 
                                                   sharedApplication].delegate;
    if (appDelegate.mainViewController) {
		UIViewController *activeController = ((RNMainViewController *)appDelegate.mainViewController).activeViewController;
		if ([activeController isKindOfClass: UINavigationController.class ]) {
			UINavigationController *nav = (UINavigationController *) activeController;
			[nav pushViewController:albumViewController animated:YES];
		}
    }
    [albumViewController release];
}
//收藏照片
- (void)favPhoto{
    if (self.currentPhotoItem) {
        if(_albumInfo.visible != AlbumVisibleAll || _albumInfo.hasPassword){ 
            [self showSimpleHUD:NSLocalizedString(@"用户设置的权限不能分享", @"用户设置的权限不能分享")];
            return;
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        if ([self.currentPhotoItem.pid longLongValue] == [_photoId longLongValue]) {
            [dict setObject:_shareId ? _shareId :self.currentPhotoItem.pid forKey:@"id"];
            [dict setObject:_shareUid ? _shareUid : self.currentPhotoItem.userId forKey:@"uid"];
            [dict setObject:[NSNumber numberWithInt:RRShareTypePhotoForPage] forKey:@"source_type"];
        }else {
            [dict setObject:self.currentPhotoItem.pid forKey:@"id"];
            [dict setObject:self.currentPhotoItem.userId forKey:@"uid"];
            [dict setObject:[NSNumber numberWithInt:RRShareTypePhoto] forKey:@"source_type"];
        }
        
        [dict setObject:[NSNumber numberWithInt:1] forKey:@"type"];
        RNPublisherViewController *publish=[[RNPublisherViewController alloc] initWithInfo:dict];
        publish.publishType = EPublishShareType;
        [self presentModalViewController:publish animated:YES];
        [publish release];
    }
}

//查看照片地点
- (void)lookupPhotoLbs{
    
}
static NSInteger compareString(id str1, id str2, void *context)
{
	return [((NSString*)str1) compare:str2 options:NSLiteralSearch];
}
//删除照片
- (void)deletePhoto{
    //****进行删除／加入发送队列 start****//
    RCConfig *config = [RCConfig globalConfig]; 
    NSMutableDictionary* query = [NSMutableDictionary dictionary];
    
    [query setObject:_mainUser.sessionKey forKey:@"session_key"];
    [query setObject:self.currentPhotoItem.pid forKey:@"pid"];
    [query setObject:config.apiKey forKey:@"api_key"];
    NSString *callId = [[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] stringValue];
	[query setObject:callId forKey:@"call_id"];
	[query setObject:config.clientInfo forKey:@"client_info"];
	[query setObject:@"1.0" forKey:@"v"]; 
	[query setObject:@"json" forKey:@"format"];
	
	/***** 计算sig start*****/
	NSEnumerator *e = [query keyEnumerator];
	NSString* theKey; 
	NSMutableArray *unsorted = [[NSMutableArray alloc] initWithCapacity:0];
	while (theKey = [e nextObject]) {
		
		NSString *value = [query objectForKey:theKey];
		if (value 
			&& [value isKindOfClass:[NSString class]] 
			&& value.length > 50) {
			
			value = [value substringToIndex:50];
		}
		NSString *aPair = [NSString stringWithFormat:@"%@=%@", theKey, value];
		[unsorted addObject:aPair];//逐个加入参数对
	}

    NSArray *sortedArray = [unsorted
							sortedArrayUsingFunction:compareString context:NULL];
    [unsorted release];
	
	NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:0];
	
	NSEnumerator *i = [sortedArray objectEnumerator];
	
	id theObject;
	
	while (theObject = [i nextObject]) {
		[buffer appendString:theObject];
	}
	
	[buffer appendString:[RCMainUser getInstance].userSecretKey];
	
	NSString* sig = [buffer md5];
	
	[buffer release];
    /***** 计算sig end*****/
	[query setObject:sig forKey:@"sig"]; //参数对中加入sig
    

    NSString *loginUrl = config.apiUrl;
    NSString* hostname = [NSString stringWithFormat:@"%@/%@", loginUrl, @"photos/delete"];
	RCBasePost *post = [[RCBasePost alloc] initWithURLString:hostname params:query httpMethod:@"POST"];
    post.postState.sendTime = callId;
    post.postState.title = [NSString stringWithFormat:NSLocalizedString(@"删除照片", @"删除照片")];
	RCMainSendQueue *mainSendQueue = [RCMainSendQueue sharedMainQueue];
	[mainSendQueue addToLinearQueue: post];
    [post release];
    //****进行删除／加入发送队列 start****//
    
    // 更新当前UI
    if (_currentPhotoIndex < [self.model.items count]) {
        // 删除当前照片
        [self.model.items removeObjectAtIndex:_currentPhotoIndex];
        -- self.model.totalItem;
        RNScrollImageView *currentPhotoView = (RNScrollImageView *)[_photosScrollView viewWithTag:
                                                                    kTagPhotoBase + _currentPhotoIndex];
        if (currentPhotoView) {
            [currentPhotoView removeFromSuperview];
        }
        // 重新布局
        [self adjustSubviews];
    }
    
    
    // 让照片墙重新加载数据
    if (self.model) {
        for (NSObject *dele in self.model.delegates) {
            if ([dele isKindOfClass:[RNAlbumWaterViewController class]]) {
                RNAlbumWaterViewController *vc = (RNAlbumWaterViewController *)dele;
                [vc reloadFlowViewData];
            }
        }
    }
}

//查看原作者
- (void)lookupAuthor{
//    [self dismissModalViewControllerAnimated:NO];
//    RCUser *rcUser = [[RCUser alloc] initWithUserId:self.currentPhotoItem.userId];
//    RNUserHomeViewController *uhvc = [[RNUserHomeViewController alloc] initWithUserInfo:rcUser];
//    RSAppDelegate *appDelegate = (RSAppDelegate *)[UIApplication sharedApplication].delegate;
//    if (appDelegate.mainViewController) {
//        [appDelegate.mainViewController.activeContentViewController pushViewController:uhvc animated:NO];
//    }
//    [rcUser release];
//    [uhvc release];
}
 
//分享照片
- (void)sharePhoto{
    if (self.currentPhotoItem) {
        if(_albumInfo.visible != AlbumVisibleAll || _albumInfo.hasPassword){ 
            [self showSimpleHUD:NSLocalizedString(@"用户设置的权限不能分享", @"用户设置的权限不能分享")];
            return;
        }
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        if ([self.currentPhotoItem.pid longLongValue] == [_photoId longLongValue]) {
            [dict setObject:_shareId ? _shareId :self.currentPhotoItem.pid forKey:@"id"];
            [dict setObject:_shareUid ? _shareUid : self.currentPhotoItem.userId forKey:@"uid"];
            [dict setObject:[NSNumber numberWithInt:RRShareTypePhotoForPage] forKey:@"source_type"];
        }else {
            [dict setObject:self.currentPhotoItem.pid forKey:@"id"];
            [dict setObject:self.currentPhotoItem.userId forKey:@"uid"];
            [dict setObject:[NSNumber numberWithInt:RRShareTypePhoto] forKey:@"source_type"];
        }
        
        [dict setObject:[NSNumber numberWithInt:0] forKey:@"type"];
        RNPublisherViewController *publish=[[RNPublisherViewController alloc] initWithInfo:dict];
        publish.publishType = EPublishShareType;
        [self presentModalViewController:publish animated:YES];
        [publish release];
    }
}

//设置用户头像 
- (void)resetUserHead{
    
}
#pragma mark - RNScrollViewDelegate
- (RNScrollImageView *)photoImageViewForIndex:(NSUInteger)index{
    RNScrollImageView  *photoView = [self dequeueReusablePhotoImageView];
    if (photoView == nil) {
        photoView = [[[RNScrollImageView alloc] init] autorelease];
    }
    photoView.RNScrollImageViewDelegate = self;
    photoView.frame = CGRectMake(index * _rWidth, 0, _rWidth, _rHeight);
    photoView.tag = kTagPhotoBase + index;
    
    NSString *urlString = [self suitableImageCachedUrl:[self.model photoItemForIndex:index]];
   if(urlString){
        photoView.image = [UIImage imageWithData:[RNFileCacheManager dataWithFileName:urlString]];
    }else{
        [photoView resetDefaultStatus];
    }
    return photoView;
}
- (RNScrollImageView *)dequeueReusablePhotoImageView
{
	if(_arrReusePhotoImageViews &&  [_arrReusePhotoImageViews count] > 0)
	{
		RNScrollImageView *photoView = [_arrReusePhotoImageViews lastObject];
		[photoView retain];
		[_arrReusePhotoImageViews removeLastObject];
		return [photoView	 autorelease];
	}
	return nil;
}

- (void)addPhotoImageViewToReuseQueue:(RNScrollImageView *)photoView{
    if (_arrReusePhotoImageViews == nil) {
        _arrReusePhotoImageViews = [[NSMutableArray alloc] initWithCapacity:5];
    }
    photoView.tag = 0;
    [_arrReusePhotoImageViews addObject:photoView];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _rWidth = 320;
        _rHeight = 480;
    }else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        _rWidth = 480;
        _rHeight = 320;
    }
    [self adjustSubviews];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	NSLog(@"interfaceOrientation = %d",interfaceOrientation);
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown); 
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_photosScrollView == scrollView) {
        if (!isKeepIndex) {
            _currentPhotoIndex = scrollView.contentOffset.x / _rWidth;
            _narBarTitleLabel.text = [NSString stringWithFormat:@"%d/%d",_currentPhotoIndex + 1,self.model.totalItem];
            [self adjustBottomView];
            [self preparePreNextPhotoImage];
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_photosScrollView == scrollView) {
        //隐藏快速浏览View
        if ((int)_quickButton.left == (int)(_rWidth - 31 - 125 + 6)){
            [self changeQuickTableView:nil];
        }

        if (_miniPublisherView) {
            [_miniPublisherView pullViewDown];
        }
        //准备前后图片
        [self preparePreNextPhotoImage];
        [self removePhotoImageOutofVisibleView];        
        // 剩余3张照片时加载下页数据
        if (_currentPhotoIndex >= [self.model.items count] - 5) {
            if (self.model.currentPageIdx < self.model.totalPage) {
                [self showDataIndicator];
                [self.model load:YES];
            }
        }
       
        [self scrollAlbumController];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_photosScrollView == scrollView) {
        [self removePhotoImageOutofVisibleView];
        [self displayCurrentLargePhoto];
        RNPhotoItem *item = self.currentPhotoItem;
        if (item && _miniPublisherView) {
            if (_shareId && [item.pid longLongValue] == [_photoId longLongValue]) {
                _miniPublisherView.commentType = ECommentShareType;
                [_miniPublisherView resetQuery:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_shareId,_shareUid, nil] 
                                                                           forKeys:[NSArray arrayWithObjects:@"id",@"user_id", nil]]
                               andCommentCount:item.commentCount];
            }else {
                _miniPublisherView.commentType = ECommentPhotoType;
                [_miniPublisherView resetQuery:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:item.pid,item.userId, nil] 
                                                                           forKeys:[NSArray arrayWithObjects:@"pid",@"uid", nil]]
                               andCommentCount:item.commentCount];
            }
        }
    }
    if (scrollView == _quickTableView) {
        [self performSelectorOnMainThread:@selector(loadImagesForOnscreenRows) withObject:nil waitUntilDone:NO];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate && scrollView == _quickTableView) {
        [self performSelectorOnMainThread:@selector(loadImagesForOnscreenRows) withObject:nil waitUntilDone:NO];
    }
}
#pragma mark - self private
- (NSString *)suitableImageUrl:(RNPhotoItem *)item{
    if (_networkStatus == ReachableViaWiFi) {
        return  item.imgMain;
    }
    return item.imgHead;
}
- (NSString *)suitableImageCachedUrl:(RNPhotoItem *)item{
    if (item) {
        if([RNFileCacheManager isCachedFileWithFileName:item.imgLarge])
            return item.imgLarge;
        if([RNFileCacheManager isCachedFileWithFileName:item.imgMain])
            return item.imgMain;
        if([RNFileCacheManager isCachedFileWithFileName:item.imgHead])
            return item.imgHead;
    }
    return nil;
}

- (void)preparePreNextPhotoImage{
    
    if (_currentPhotoIndex >= 1 &&
        ![_photosScrollView viewWithTag:(kTagPhotoBase + _currentPhotoIndex - 1)]) {
        
        RNScrollImageView *prePhotoView = [self photoImageViewForIndex:(_currentPhotoIndex - 1)];
        [_photosScrollView addSubview:prePhotoView];
    }
    if (_currentPhotoIndex < [self.model.items count] - 1 && 
        ![_photosScrollView viewWithTag:(kTagPhotoBase + _currentPhotoIndex + 1)]) {
        RNScrollImageView *nextPhotoView = [self photoImageViewForIndex:(_currentPhotoIndex + 1)];
        [_photosScrollView addSubview:nextPhotoView];
    }
}
- (void)removePhotoImageOutofVisibleView{
    for (int i = [[_photosScrollView subviews] count] - 1 ; i >= 0; i--) {
        @autoreleasepool {
            RNScrollImageView *photoView = [[_photosScrollView subviews] objectAtIndex:i];
            if (photoView.frame.origin.x < (_currentPhotoIndex - 1) * _photosScrollView.width || 
                photoView.frame.origin.x > (_currentPhotoIndex + 1) * _photosScrollView.width ) {
                [self addPhotoImageViewToReuseQueue:photoView];
                [photoView removeFromSuperview];
            }
        }
    }
}
- (void)scrollAlbumController{
    //让父controller滚动
    if (self.model) {
        for (NSObject *dele in self.model.delegates) {
            if ([dele isKindOfClass:[RNAlbumWaterViewController class]]) {
                RNAlbumWaterViewController *vc = (RNAlbumWaterViewController *)dele;
                [vc scrollToFlowViewAtIndex:_currentPhotoIndex];
            }
        }
    }
}
- (void)showDataIndicator{
    if ([self.view viewWithTag:kTagActivity]) {
        return;
    }
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.tag = kTagActivity;
    activityIndicatorView.center = CGPointMake(_rWidth/2, _rHeight/2);
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView release];
    [activityIndicatorView startAnimating];
    [self.view bringSubviewToFront:activityIndicatorView];
}
- (void)adjustBottomView{

    RNPhotoItem *item = self.currentPhotoItem;
    if (item) {
        if (_miniPublisherView == nil) {
            _miniPublisherView = [[RNMiniPublisherView alloc] 
                                  initWithFrame:CGRectMake(0, _rHeight - kPublisherViewHeight, _rWidth, kPublisherViewHeight) 
                                                             andCommentType:ECommentPhotoType 
															   isBlackStyle: YES]; //chenyi modify
            _miniPublisherView.bIsShowCommentCount = YES;
            _miniPublisherView.miniPublisherDelegate = self;
            if (_miniPublisherView) {
                if (_shareId && [item.pid longLongValue] == [_photoId longLongValue]) {
                    _miniPublisherView.commentType = ECommentShareType;
                    [_miniPublisherView resetQuery:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_shareId,_shareUid, nil] 
                                                                               forKeys:[NSArray arrayWithObjects:@"id",@"user_id", nil]]
                                   andCommentCount:item.commentCount];
                }else {
                    _miniPublisherView.commentType = ECommentPhotoType;
                    [_miniPublisherView resetQuery:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:item.pid,item.userId, nil] 
                                                                               forKeys:[NSArray arrayWithObjects:@"pid",@"uid", nil]]
                                   andCommentCount:item.commentCount];
                }
            }
            _miniPublisherView.parentControl = self;
            [self.view addSubview:_miniPublisherView];
            [_miniPublisherView release];
        }
		CGSize size;
        if (item.caption) {
			size = [item.caption sizeWithFont:[UIFont systemFontOfSize:16] 
                                   constrainedToSize:CGSizeMake(_rWidth - 10, 2000) 
                                       lineBreakMode:UILineBreakModeCharacterWrap];
		}else {
			
			size = CGSizeZero;
		}
        
        int maxSizeHeight = (int)_rHeight == 320 ? 60 :100;
        size = CGSizeMake(_rWidth - 10, size.height  > maxSizeHeight ? maxSizeHeight :size.height);
        CGFloat lbsViewHeight = item.lbsItem ? 22 : 0;
        CGFloat bHeight = size.height + 20 + lbsViewHeight; 
        
        if (![UIApplication sharedApplication].isStatusBarHidden && (int)_narBarView.top == 20) {
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                _bottomView.frame = CGRectMake(0, _rHeight - bHeight, _rWidth, bHeight);
                _miniPublisherView.frame = CGRectMake(0,_rHeight, _rWidth, kPublisherViewHeight);
            }else {
                _bottomView.frame = CGRectMake(0, _rHeight - bHeight - kPublisherViewHeight + 4, _rWidth, bHeight);
                _miniPublisherView.frame = CGRectMake(0,_rHeight - kPublisherViewHeight, _rWidth, kPublisherViewHeight);
            }
        }else {
            _bottomView.frame = CGRectMake(0, _rHeight, _rWidth, bHeight);
            _miniPublisherView.frame = CGRectMake(0,_rHeight, _rWidth, kPublisherViewHeight);
        }
        
        _photoDescLable.frame = CGRectMake(5, 0, _rWidth - 10, size.height);
        _viewShareCountLable.frame = CGRectMake(5, size.height, _rWidth - 10, 20);
        _locationImageView.frame = CGRectMake(5, size.height + 20, 25, lbsViewHeight);
        _locationButton.frame = CGRectMake(5 + 25 + 5, size.height + 20, _rWidth - 10 - 25 - 5, lbsViewHeight);

        _photoDescLable.text = item.caption;
        _viewShareCountLable.text = [NSString stringWithFormat:NSLocalizedString(@"浏览%d次", @"浏览%d次"),item.viewCount,nil];
        [_locationButton setTitle:item.lbsItem ? item.lbsItem.pname : @"" forState:UIControlStateNormal];
       
    }
}
- (RNPhotoItem *)currentPhotoItem{
    return _dataLoadStatus == DataLoadStatusAlbumFirstFinished ? [self.model photoItemForIndex:_currentPhotoIndex] : _firstPhotoItem;
}
#pragma mark - tableviewdelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 112;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _currentPhotoIndex = indexPath.row;
    [self adjustSubviews];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.model.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"photocell";
    RNQuickViewPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[[RNQuickViewPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:cellIdentifier] autorelease];
	} 

    NSString *urlString = [self suitableImageCachedUrl:[self.model photoItemForIndex:indexPath.row]];
    if(urlString)
	{
        cell.contentImageView.image = [RLUtility getCentralSquareImage:[UIImage imageWithData:[RNFileCacheManager dataWithFileName:urlString]] 
                                                            Length:95];
    }else {
        cell.contentImageView.image = [[RCResManager getInstance] imageForKey:@"photo_quick_default"];
    }
    
    return cell;
}
#pragma mark - loadImagesForOnscreenRows
- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [_quickTableView  indexPathsForVisibleRows];	
    for (NSIndexPath *indexPath in visiblePaths) {	
   		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   		RNQuickViewPhotoCell *cell = (RNQuickViewPhotoCell *)[_quickTableView cellForRowAtIndexPath:indexPath];
        NSString *urlStringCached = [self suitableImageCachedUrl:[self.model photoItemForIndex:indexPath.row]];
        NSString *urlString = [self suitableImageUrl:[self.model photoItemForIndex:indexPath.row]];
        if (![urlString isEqualToString:urlStringCached]) {
            MKNetworkOperation *op = [_networkEngine operationWithURLString:urlString];
            [op onCompletion:^(MKNetworkOperation *completedOperation) {
                NSData *data = [completedOperation responseData];
                [RNFileCacheManager cacheFileWithData:data withFileName:urlString];
                cell.contentImageView.image = [RLUtility getCentralSquareImage:[UIImage imageWithData:data] 
                                                                 Length:95];
            } onError:^(NSError *error) {
            }];
            [_networkEngine enqueueOperation:op];
        } else {
            cell.contentImageView.image = [RLUtility getCentralSquareImage:
                                           [UIImage imageWithData:[RNFileCacheManager dataWithFileName:urlStringCached]] 
                                                                    Length:95];
        }
        [pool release];
    }		
}

#pragma mark - LoadCurrentPhotoLarge
- (void)displayCurrentLargePhoto{
   
    //隐藏其他HUD
    for (int i = self.view.subviews.count - 1 ; i >= 0 ;i--) {
        UIView *v = [self.view.subviews objectAtIndex:i];
        if ([v isKindOfClass:[MBProgressHUD class]] && v.tag != kTagHUD + _currentPhotoIndex) {
            MBProgressHUD *HUD = (MBProgressHUD *)v;
            [HUD hide:YES];
        }
    }
    
    RNScrollImageView *currentPhotoView = (RNScrollImageView *)[_photosScrollView viewWithTag:
                                                                kTagPhotoBase + _currentPhotoIndex];
    if (currentPhotoView == nil) {
        return;
    }
    NSString *imgLarge = [self.model photoItemForIndex:_currentPhotoIndex].imgLarge;
    NSString *urlString = [self suitableImageCachedUrl:[self.model photoItemForIndex:_currentPhotoIndex]];
    if (urlString) {
        currentPhotoView.image = [UIImage imageWithData:[RNFileCacheManager dataWithFileName:urlString]];
    }
    if ([urlString isEqualToString:imgLarge]) {
        return;
    }
    //取消其他下载
    for (MKNetworkOperation *op in _networkEngine.operationInsharedQueue) {
        if (op.isExecuting && [op.url isEqualToString:imgLarge]) {
            NSLog(@"url ...%@...%@",op.url,imgLarge);
//            [op cancel];
            return;
        }
    }
    MBProgressHUD *HUD = [self showHUDIndicator:_currentPhotoIndex];
//    __block typeof(self) self = self;
    MKNetworkOperation *op = [_networkEngine operationWithURLString:imgLarge];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSData *data = [completedOperation responseData];
        currentPhotoView.image = [UIImage imageWithData:data];
        [RNFileCacheManager cacheFileWithData:data withFileName:imgLarge];
        [HUD hide:YES];
        if ((int)_quickButton.left == _rWidth - 31 - 125 + 6) {
            [self performSelectorOnMainThread:@selector(loadImagesForOnscreenRows) withObject:nil waitUntilDone:NO];
        }
    } onError:^(NSError *error) {
        
    }];
    [op onDownloadProgressChanged:^(double progress) {
        HUD.progress = progress;
    }];
    [_networkEngine enqueueOperation:op];
}
- (MBProgressHUD *)showHUDIndicator:(NSInteger)index{
    if ([self.view viewWithTag:kTagHUD + index]) {
        return (MBProgressHUD *)[self.view viewWithTag:kTagHUD + index];
    }
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
    HUD.center = CGPointMake(_rWidth/2, _rHeight/2);
	[self.view addSubview:HUD];
    HUD.tag = kTagHUD + index;
	HUD.mode = MBProgressHUDModeDeterminate;
    HUD.square = NO;
	HUD.delegate = self; 
	HUD.labelText = NSLocalizedString(@"加载中", @"加载中");
    [HUD show:YES];
    return HUD;
}
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

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
	[hud release];
     hud = nil;
}
#pragma mark - RNModelDelegate
// 开始
- (void)modelDidStartLoad:(RNPhotoListModel *)model {
    // 子类实现
    [self showDataIndicator];
    if (_dataLoadStatus == DataLoadStatusAlbumInfoLoaded) {
        _dataLoadStatus = DataLoadStatusAlbumFirstLoading;
    }
}

// 完成
- (void)modelDidFinishLoad:(RNPhotoListModel *)model {
    // 子类实现
    UIView *view = [self.view viewWithTag:kTagActivity];
    if (view) {
        [view removeFromSuperview];
    }
    
    if ([self.model.items count] <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"该相册暂无照片。", @"该相册暂无照片。")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"确定", @"确定") 
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    if (_dataLoadStatus == DataLoadStatusAlbumFirstLoading) {
        _dataLoadStatus = DataLoadStatusAlbumFirstFinished;
        for (int i=0; i<[model.items count]; i++) {
            RNPhotoItem *item = [model photoItemForIndex:i];
            if (item) {
                if ([item.pid longLongValue] == [_photoId longLongValue]) {
                    _currentPhotoIndex = i;
                    break;
                }
            }
        }
    }
    [_quickTableView reloadData];
    [self adjustSubviews];
    
}

// 错误处理
- (void)model:(RNPhotoListModel *)model didFailLoadWithError:(RCError *)error {
    // 子类实现
    [self showAlertForError:error];
}

// 取消
- (void)modelDidCancelLoad:(RNPhotoListModel *)model {
    // 子类实现
}

#pragma mark - request album info
- (void)requestPhotoInfo{
    NSMutableDictionary* dics = [NSMutableDictionary dictionary];
    [dics setObject:_mainUser.sessionKey forKey:@"session_key"];
    [dics setObject:_photoId forKey:@"pid"];
    [dics setObject:_userId forKey:@"uid"];
    [dics setObject:[NSNumber numberWithInt:1] forKey:@"with_lbs"];
    NSString *password = self.tInputPassword.text;
    if(password){
        [dics setObject:password forKey:@"password"];
    }
    RCGeneralRequestAssistant *mReqAssistant = [RCGeneralRequestAssistant requestAssistant];
//    __block typeof(self) self = self;
    mReqAssistant.onCompletion = ^(NSDictionary* result){
        _dataLoadStatus = DataLoadStatusCurrentPhotoFinished;
        if (result) {
            _firstPhotoItem = [[RNPhotoItem alloc] initWithDictionary:result];
            [self requestAlbumInfo];
        }
    };
    mReqAssistant.onError = ^(RCError* error) {
        NSLog(@"error....%@",error.titleForError);
        [self showAlertForError:error];
    };
    _dataLoadStatus = DataLoadStatusCurrentPhotoLoading;
    [mReqAssistant sendQuery:dics withMethod:@"photos/get"];
    [self showDataIndicator];
}
#pragma mark - request album info
- (void)requestAlbumInfo{
    NSMutableDictionary* dics = [NSMutableDictionary dictionary];
    [dics setObject:_mainUser.sessionKey forKey:@"session_key"];
    [dics setObject:_firstPhotoItem.albumId forKey:@"aid"];
    [dics setObject:_userId forKey:@"uid"];
    NSString *password = self.tInputPassword.text;
    if(password){
        [dics setObject:password forKey:@"password"];
    }
    RCGeneralRequestAssistant *mReqAssistant = [RCGeneralRequestAssistant requestAssistant];
//    __block typeof(self) self = self;
    mReqAssistant.onCompletion = ^(NSDictionary* result){
        _dataLoadStatus = DataLoadStatusAlbumInfoLoaded;
        if (result) {
            _albumInfo = [[RNAlbumItem alloc] initWithDictionary:result];
            _narBarFirstBtn.hidden = _albumInfo.visible != AlbumVisibleAll || _albumInfo.hasPassword;
            
            RNPhotoListModel *model = [[RNPhotoListModel alloc] initWithAid:_firstPhotoItem.albumId withUid:_userId];
            self.model = model;
            [self.model.query setObject:[NSNumber numberWithInt:1] forKey:@"all"];
            if(password){
                [self.model.query setObject:password forKey:@"password"];
            }
            [self.model.delegates addObject:self];
            [model release];
            //FIXME 危险
            [self.model.items addObject:_firstPhotoItem];
            self.model.totalItem = 1;
            [self adjustSubviews];
            [self.model load:NO];
        }
    };
    mReqAssistant.onError = ^(RCError* error) {
        NSLog(@"error....%@",error.titleForError);
        //不处理该错误信息
    };
    _dataLoadStatus = DataLoadStatusAlbumInfoLoading;
    [mReqAssistant sendQuery:dics withMethod:@"photos/getAlbums"];
    
}
#pragma mark - UIAlertView
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
											  otherButtonTitles:NSLocalizedString(@"确定", @"确定"), NSLocalizedString(@"取消", @"取消"), nil];
        
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
		[self.tAlert addSubview:self.tInputPassword];
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
		NSString *password = self.tInputPassword.text;
		if(password){
            [self requestPhotoInfo];
		}else {
            [self showAlertForPwd];
        }
	}else {
        [self dismissModalViewControllerAnimated:_startSource == PhotoStartSourceShare];
    }
}
- (void)showAlertForError:(RCError *)error{
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
#pragma mark -  RNScrollImageViewDelegate

- (void)touchOneCountBegin:(RNScrollImageView  *)scrollImageView{
    if (_miniPublisherView) { //chenyi 修改
        [_miniPublisherView pullViewDown];
    }
    [UIView animateWithDuration:.3
                          delay:0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         _quickArrImageView.transform = CGAffineTransformIdentity;
                         if ([UIApplication sharedApplication].isStatusBarHidden) {
                             [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                                     withAnimation:UIStatusBarAnimationFade|UIStatusBarAnimationSlide];
                             _narBarView.hidden = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
                             _narBarView.frame = CGRectMake(0, 20, _rWidth, 44);
                             _quickButton.frame = CGRectMake(_rWidth - 31, (_rHeight - 85)/2, 31, 85);
                              _quickArrImageView.center =  CGPointMake(_quickButton.center.x + 6.5, _quickButton.center.y);
                             _quickBgView.frame = CGRectMake(_rWidth, 20, 125, _rHeight - 20);
                             _quickTableView.frame = CGRectMake(13, 1, 105, _quickBgView.height - 1);
                             if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                                 _bottomView.frame = CGRectMake(0, _rHeight -  _bottomView.height, _rWidth, _bottomView.height);
                                 _miniPublisherView.frame = CGRectMake(0,_rHeight, _rWidth, kPublisherViewHeight);
                             }else {
                                 _bottomView.frame = CGRectMake(0, _rHeight -  _bottomView.height - kPublisherViewHeight + 4,
                                                                _rWidth,  _bottomView.height);
                                 _miniPublisherView.frame = CGRectMake(0,_rHeight - kPublisherViewHeight, _rWidth, kPublisherViewHeight);
                             }
                        }else {
                             _narBarView.frame = CGRectMake(0, -44, _rWidth, 44);
                             _quickButton.frame = CGRectMake(_rWidth, (_rHeight - 85)/2, 31, 85);
                              _quickArrImageView.center =  CGPointMake(_quickButton.center.x + 6.5, _quickButton.center.y);
                             _quickBgView.frame = CGRectMake(_rWidth, 20, 125, _rHeight - 20);
                             _quickTableView.frame = CGRectMake(13, 1, 105, _quickBgView.height - 1);
                             _bottomView.frame = CGRectMake(0, _rHeight, _rWidth, _bottomView.height);
                             _miniPublisherView.frame = CGRectMake(0,_rHeight, _rWidth, kPublisherViewHeight);
                             [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                                     withAnimation:UIStatusBarAnimationFade|UIStatusBarAnimationSlide];
                         }
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}
-(void)lsbAction:(id)sender{
//    if (self.currentPhotoItem && self.currentPhotoItem.lbsItem) {
//        NSString *url = [NSString stringWithFormat:@"http://%@/place/poi/%@/%ld?no_feed=1",
//                         [HummerSettings shareInstance].defaultHost,
//                         [self.currentPhotoItem.userId stringValue],
//                         self.currentPhotoItem.lbsItem.lbsId ];
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
#pragma mark - RNMiniPublisherDelegate
- (void)onClickCommentCountButton{
//    if (self.currentPhotoItem) {
//        NSString *url = [NSString stringWithFormat:@"http://%@/photo/%@/%@/comments?no_feed=1",
//                         [HummerSettings shareInstance].defaultHost,
//                         [self.currentPhotoItem.userId stringValue],
//                         [self.currentPhotoItem.pid stringValue]];
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
//    
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

@implementation RNQuickViewPhotoCell
@synthesize contentImageView = _contentImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
        self.contentView.backgroundColor = [UIColor clearColor];
        UIView *selectedView = [[UIView alloc] initWithFrame:self.contentView.frame];
        selectedView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedView;
        [selectedView release];
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 105, 105)];
        _bgImageView.image = [[[RCResManager getInstance] imageForKey:@"album_cell_bg"] stretchableImageWithLeftCapWidth:8.5 topCapHeight:8.5];
        [self addSubview:_bgImageView];
        [_bgImageView release];
        
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 12, 95, 95)];
        [self addSubview:_contentImageView];
        [_contentImageView release];
        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}



@end
