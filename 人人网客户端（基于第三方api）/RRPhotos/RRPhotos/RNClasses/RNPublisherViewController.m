//
//  RNInputViewController.m
//  RRSpring
//
//  Created by 黎 伟 ✪ on 3/6/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//  edit by 玉平 孙

#import "RNPublisherViewController.h"
#import "RCMainUser.h"
#import "RNPublishBigCommentViewController.h"
#import "RNCommentViewController.h"
#import "RNMiniPublisherView.h"

//#import "RNPublishReportViewController.h"
//#import "RNPublishBlogViewController.h" 
#import "RNPlaceEvaluationViewController.h"
#import "RNPublishStateViewController.h"
#import "RNAddFriendsViewController.h"
//#import "RNNavigationController.h"
//#import "AppDelegate.h"
#import "RNPublishGossipViewController.h"

#import "RNEmotionCacheManager.h"

@implementation RNPublisherViewController
@synthesize accessoryBar=_accessoryBar;
@synthesize currentViewControl=_currentViewControl;
@synthesize currentPrgam=_currentPrgam;
@synthesize requestDelegate=_requestDelegate;
@synthesize publishType=_publishType;
- (void)dealloc{
    [_accessoryBar release];
    [_currentViewControl release];
  //  [_currentPrgam release];
    [super dealloc];
}
-(void)chickPrgam{
    if ([self.currentPrgam objectForKey:@"title"] == nil) {
        [self.currentPrgam setObject:@" " forKey:@"title"];
    }
    if ([self.currentPrgam objectForKey:@"action"] == nil) {
        [self.currentPrgam setObject:NSLocalizedString(@"完成", @"完成") forKey:@"action"];
    }
    if ([self.currentPrgam objectForKey:@"method"] == nil) {
        [self.currentPrgam setObject:@" " forKey:@"action"];
    }
}
-(id)initWithInfo:(NSMutableDictionary*)info{
    self = [super init];
    if (self) {
        self.currentPrgam = [NSMutableDictionary dictionaryWithDictionary:info];
        // self.bottombar.audioButtonEnable = NO;
        // self.bottombar.photoButtonEnable = NO;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(NSString*)getValueBykey:(NSString*)key isDeleate:(BOOL)del{
    NSString *val = [self.currentPrgam objectForKey:key];
    if (del) {
        [self.currentPrgam removeObjectForKey:key];
    }
    return val;
}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    
//    RCMainUser* mainUser = [RCMainUser getInstance];
//
//    NSString *userid = [mainUser.userId stringValue];
//    NSString *sigid = mainUser.ticket ;
    CGRect viewframe = CGRectMake(0, 
                                  0,
                                  PHONE_SCREEN_SIZE.width,
                                  CONTENT_NAVIGATIONBAR_HEIGHT);
    // 设置navigationBar 
    RNPublisherAccessoryBar * titlebar = [[RNPublisherAccessoryBar alloc] initWithFrame:viewframe];
    self.accessoryBar = titlebar;
    [titlebar release];
    
    if (self.currentPrgam ) {
        if([(NSString*)[self.currentPrgam objectForKey:@"publishertype"] intValue]){
            _publishType =  [(NSString*)[self.currentPrgam objectForKey:@"publishertype"] intValue];
        }
    }
    //for test
    //_publishType = EPublishGossipType;
    
    switch (_publishType) {
        case EPublishStatusType ://发布状态
        {
            self.accessoryBar.title = NSLocalizedString(@"发布状态", @"发布状态");
            [self.accessoryBar.rightButton setTitle:NSLocalizedString(@"发布", @"发布") forState:UIControlStateNormal];
            RNPublishStateViewController *stateviewcon = [[RNPublishStateViewController alloc] init] ;
            self.currentViewControl = stateviewcon;
            [stateviewcon release];
         }
            break;
        case EPublishPhotoType ://上传照片
        {
            self.accessoryBar.title =NSLocalizedString( @"上传照片",  @"上传照片");
            [self.accessoryBar.rightButton setTitle:NSLocalizedString(@"上传", @"上传") forState:UIControlStateNormal];
            RNPublishStateViewController *photoviewcon = [[RNPublishStateViewController alloc] init];
            self.currentViewControl = photoviewcon;
            if([self.currentPrgam objectForKey:@"publisherimage"]){
                UIImage *imagedata =  (UIImage*)[self.currentPrgam objectForKey:@"publisherimage"] ;
                [photoviewcon setSelectPhoto:imagedata];
            }
            if([self.currentPrgam objectForKey:@"id"]){
                NSString *imageid = [[self.currentPrgam objectForKey:@"id"] stringValue] ;
                [photoviewcon.currentPrgam setObject:imageid forKey:@"aid"];
            }
            [photoviewcon release];
                        
        }
            break;
        case EPublishReportType ://报道
        {
//            self.accessoryBar.title = NSLocalizedString(@"报道", @"报道");
//            [self.accessoryBar.rightButton setTitle:NSLocalizedString(@"发布", @"发布") forState:UIControlStateNormal];
//    
//            RNPublishReportViewController *locationviewcon = [[RNPublishReportViewController alloc] initWithInfo:self.currentPrgam] ;
//            self.currentViewControl = locationviewcon;
//            [locationviewcon release];
        }
            break;
        case EPublishEvaluationType ://评价地点
        {
			self.accessoryBar.title = NSLocalizedString(@"推荐给好友", @"推荐给好友");
			[self.accessoryBar.rightButton setTitle:NSLocalizedString(@"推荐", @"推荐") forState:UIControlStateNormal];
			
			RNPlaceEvaluationViewController *evaluatViewController = [[RNPlaceEvaluationViewController alloc]initWithInfo:self.currentPrgam];
			self.currentViewControl = evaluatViewController;
			[evaluatViewController release];
		}
            break;
        case EPublishEvaluationCommentType ://评价地点的回复
        {
            
        }
            break;
        case EPublishShareType ://分享
        {
            //RRShareType sharetype =(RRShareType)[self.currentPrgam objectForKey:@"RRShareType"];
            RNCommentViewController *shareviewcon =[[RNCommentViewController alloc] initWithInfo:self.currentPrgam];
            self.currentViewControl = shareviewcon;
            [shareviewcon release];
        }
            break;
        case EPublishFavoritesType ://收藏
        {
            RNCommentViewController *favoritesviewcon =[[RNCommentViewController alloc] initWithInfo:self.currentPrgam];
            self.currentViewControl = favoritesviewcon;
            [favoritesviewcon release];
        }
            break;
        case EPublishAddFriendType ://加好友留言
        {
			self.accessoryBar.title = NSLocalizedString(@"加好友附言", @"加好友附言");
			[self.accessoryBar.backButton setTitle:NSLocalizedString(@"取消", @"取消") forState:UIControlStateNormal];
			[self.accessoryBar.rightButton setTitle:NSLocalizedString(@"发送", @"发送") forState:UIControlStateNormal];
            RNAddFriendsViewController *addfriendviewcon =  [[RNAddFriendsViewController alloc]initWithInfo:self.currentPrgam];
			self.currentViewControl = addfriendviewcon;  
            [addfriendviewcon release];
        }
            break;
        case EPublishWriteBlogType ://写日志 
        {
//            self.accessoryBar.title = NSLocalizedString(@"写日志", @"写日志");
//            [self.accessoryBar.backButton setTitle:NSLocalizedString(@"取消", @"取消") forState:UIControlStateNormal];
//			[self.accessoryBar.rightButton setTitle:NSLocalizedString(@"发送", @"发送") forState:UIControlStateNormal];
//            RNPublishBlogViewController *blogviewcon = [[RNPublishBlogViewController alloc] init];
//            self.currentViewControl = blogviewcon;
//            [blogviewcon release];
        }
            break;
        case EPublishReplyType ://回复
        {
            
        }
            break;
        case EPublishGossipType://留言
        {
            self.accessoryBar.title = NSLocalizedString(@"留言", @"留言");
            [self.accessoryBar.backButton setTitle:NSLocalizedString(@"取消", @"取消") forState:UIControlStateNormal];
			[self.accessoryBar.rightButton setTitle:NSLocalizedString(@"发送", @"发送") forState:UIControlStateNormal];
            RNPublishGossipViewController *grossipviewcon = [[RNPublishGossipViewController alloc] initWithInfo:self.currentPrgam];
            self.currentViewControl = grossipviewcon;
            [grossipviewcon release];

        }
        default:
            break;
    }
    
    
    self.accessoryBar.publisherBarDelegate = self;
    [self.view addSubview:self.accessoryBar];
    
    self.currentViewControl.parentControl = self;
    self.currentViewControl.view.frame = CGRectMake(0, 
                                               CONTENT_NAVIGATIONBAR_HEIGHT, 
                                               PHONE_SCREEN_SIZE.width, 
                                               PHONE_SCREEN_SIZE.height-CONTENT_NAVIGATIONBAR_HEIGHT);
    [self.view addSubview:self.currentViewControl.view];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.view setBackgroundColor:[UIColor whiteColor]];
    //打开主菜单左滑动手势
//    RNNavigationController *navcon = (RNNavigationController *)self.navigationController;
//    navcon.panGestureType = EPanGestureDisable;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //self.currentViewControl =nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
/*
 * 点击左边取消按钮
 * 
 */
- (void)publisherAccessoryBarLeftButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    if (self.currentViewControl) {
        if ([self.currentViewControl respondsToSelector:@selector(publisherAccessoryBarLeftButtonClick:)] ) {
            [self.currentViewControl publisherAccessoryBarLeftButtonClick:publisherAccessoryBar ];
        }
    }
}
/*
 * 点击右边按钮
 * 
 */
- (void)publisherAccessoryBarRightButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    if (self.currentViewControl) {
        if ([self.currentViewControl respondsToSelector:@selector(publisherAccessoryBarRightButtonClick:)] ) {
            [self.currentViewControl publisherAccessoryBarRightButtonClick:publisherAccessoryBar ];
        }
    }
}
@end
