//
//  RNCommentViewController.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-30.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNCommentViewController.h"
#import "RCMainUser.h"
#import "RNCustomText.h"
#import "RNPublisherViewController.h"
//#import "RSAppDelegate.h"
@interface RNCommentViewController ()

@end

@implementation RNCommentViewController
@synthesize currentPrgam=_currentPrgam;
-(void)dealloc{
    [_baseRequest release];
    [_currentPrgam release];
    [atRequestMethod release];
    if (_commentRequest) {
        [_commentRequest release];
        _commentRequest = nil;
    }
    [super dealloc];
}
-(NSString*)getValueBykey:(NSString*)key isDeleate:(BOOL)del{
    NSString *val = [self.currentPrgam objectForKey:key];
    if (del) {
        [self.currentPrgam removeObjectForKey:key];
    }
    return val;
}
-(id)initWithInfo:(NSMutableDictionary*)info{
    RCMainUser *mainuser =[RCMainUser getInstance];
    self = [super initWithUserID:mainuser.userId];
    if (self) {
        self.currentPrgam = [NSMutableDictionary dictionaryWithDictionary:info];
        //NSString *method = [self.currentPrgam objectForKey:@"method"];
        pageType = 0;
        self.bottombar.locationButtonEnable = NO;
        self.bottombar.photoButtonEnable = NO;

    }
    return self;
}
-(void)commentcheckBoxClick:(UIButton*)btn{
     btn.selected = !btn.isSelected;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _baseRequest = [[RCBaseRequest alloc] init];
        atRequestMethod = [[NSMutableString alloc] init];
        
    }
    return self;
}
-(void)getAtPermissions{
    NSNumber *the_id = [self.currentPrgam objectForKey:@"id"];
    if (the_id == nil ) {
        return;
    }
    NSNumber *the_owner_id = [self.currentPrgam objectForKey:@"uid"];
    if (the_owner_id == nil) {
        return;
    }
    _baseRequest.onCompletion = ^(NSDictionary* result){    
        NSNumber *level = [result objectForKey:@"privacy_level"];
        if (level) {
            if ([level intValue] == 1) {
                //self.bottombar.
                self.bottombar.uid = [self.currentPrgam objectForKey:@"uid"];
                
            }else if([level intValue] == 2){
                self.bottombar.canAtFriend = NO;
            }
        }
        
        
    };
    _baseRequest.onError = ^(RCError* error) {
        
    };
    
    RCMainUser *mainuserinfo = [RCMainUser getInstance];
    NSMutableDictionary* dics = [NSMutableDictionary dictionary];
    [dics setObject:mainuserinfo.sessionKey forKey:@"session_key"];
    [dics setObject:[self.currentPrgam objectForKey:@"id"] forKey:@"id"];
    [dics setObject:[self.currentPrgam objectForKey:@"uid"] forKey:@"owner_id"];
    [_baseRequest sendQuery:dics withMethod:atRequestMethod];
}
- (void)loadView
{
    [super loadView];
    //获取@权限
    [self getAtPermissions];
    
    pageType = [(NSString*)[self getValueBykey:@"type" isDeleate:NO] intValue];
    NSMutableString *actionBtnName = [NSMutableString stringWithString:@"分享"];
    NSMutableString *title = [NSMutableString stringWithString:@"分享"];
    _sharetype = [(NSString*)[self getValueBykey:@"source_type" isDeleate:NO] intValue];
    if (pageType == 1) {
        [title setString:NSLocalizedString(@"收藏", @"收藏") ];
        [actionBtnName setString:NSLocalizedString(@"收藏", @"收藏") ];
    }else{
        self.bottombar.checkBoxViewEnable = YES;
        [self.bottombar setCheckInfo:NSLocalizedString(@"同时评论给好友", @"同时评论给好友") ];
        UIButton* checkbox_bg = (UIButton*)[self.bottombar.checkBoxView viewWithTag:10003];
        [checkbox_bg setImage:[[RCResManager getInstance] imageForKey:@"publish_checkbox"] forState:UIControlStateNormal];
        [checkbox_bg setImage:[[RCResManager getInstance] imageForKey:@"publish_checkbox_sel"] forState:UIControlStateSelected];
        [checkbox_bg  removeTarget:self.bottombar action:@selector(checkBoxClick:) forControlEvents:UIControlEventTouchDown];
        [checkbox_bg addTarget:self action:@selector(commentcheckBoxClick:) forControlEvents:UIControlEventTouchDown];
        checkbox_bg.selected = YES;
    }
    switch (_sharetype) {
        case RRShareTypeBlog:
        case RRShareTypeBlogForPage:
        {
            [title appendString:NSLocalizedString(@"收藏", @"收藏") ];
            [atRequestMethod setString:@"blog/privacy"];
        }
            break;
        case RRShareTypePhoto:
        case RRShareTypePhotoForPage:
        {
            [title appendString:NSLocalizedString(@"照片", @"照片") ];
            [atRequestMethod setString:@"photos/privacy"];
        }
            break;
        case RRShareTypeLink:
        case RRShareTypeLinkForPage:
        {
            [title appendString:NSLocalizedString(@"连接", @"连接") ];
        }
            break;
        case RRShareTypeAlbum:
        case RRShareTypeAlbumForPage:
        {
            [title appendString:NSLocalizedString(@"相册", @"相册") ];
            [atRequestMethod setString:@"photos/privacy"];
        }
            break;
        case RRShareTypeVideo:
        case RRShareTypeVideoForPage:
        {
            [title appendString:NSLocalizedString(@"视频", @"视频") ];
        }
            break;
        case RRShareTypeStatus:
        {
            [title appendString:NSLocalizedString(@"状态", @"状态") ];
        }
            break;
            
        default:
            break;
    }
    //更换标题
    RNPublisherViewController* control = (RNPublisherViewController*)self.parentControl;
    control.accessoryBar.title = title;
    [control.accessoryBar.rightButton setTitle:actionBtnName forState:UIControlStateNormal];
    
    
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
/*
 * 点击左边取消按钮
 * 
 */
- (void)publisherAccessoryBarLeftButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
		UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"是否取消发布", @"是否取消发布")  
														   message:nil
														  delegate:self 
												 cancelButtonTitle:NSLocalizedString(@"取消", @"取消") 
												 otherButtonTitles:NSLocalizedString(@"确定", @"确定") , nil];
		[alertView show];
		[alertView release];
	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (1 == buttonIndex) {
        [self.parentControl dismissModalViewControllerAnimated:YES];
	}
}


- (void)alertViewCancel:(UIAlertView *)alertView{
	[self.contentView becomeFirstResponder];
}

/*
 * 点击右边按钮
 * 
 */
- (void)publisherAccessoryBarRightButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{    
    if (self.bottombar.currentCount > self.bottombar.maxCount) {
        [self showAlertWithMsg:NSLocalizedString(@"字数超出限制哦亲!", @"字数超出限制哦亲!") ];
        return;
    }
    if (_sharetype == RRShareTypeStatus) {//转发评论
        NSMutableDictionary* dics = [NSMutableDictionary dictionaryWithDictionary:self.currentPrgam];
        [dics setObject:self.contentView.text forKey:@"status"];
        UIButton* checkbox_bg = (UIButton*)[self.bottombar.checkBoxView viewWithTag:10003];
        if (checkbox_bg.isSelected && [self.contentView.text length] > 0) {
            [dics setObject:[NSNumber numberWithInt:1] forKey:@"send_owner"];
        }
        RNPublisherViewController* control = (RNPublisherViewController*)self.parentControl;
        self.publishPost.postState.title = [NSString stringWithFormat:@"%@:%@",control.accessoryBar.title,self.contentView.text];
        [self.publishPost publishPostWith:nil paramDic:dics withMethod:@"status/forward"];
        
    }else {
        NSMutableDictionary* dics = [NSMutableDictionary dictionaryWithDictionary:self.currentPrgam];
        [dics setObject:[NSNumber numberWithInt:_sharetype] forKey:@"source_type"];
        [dics setObject:self.contentView.text forKey:@"status"];
        RNPublisherViewController* control = (RNPublisherViewController*)self.parentControl;
        self.publishPost.postState.title = [NSString stringWithFormat:@"%@:%@",control.accessoryBar.title,self.contentView.text];
        
        [self.publishPost publishPostWith:nil paramDic:dics withMethod:@"share/publish"];
        
        UIButton* checkbox_bg = (UIButton*)[self.bottombar.checkBoxView viewWithTag:10003];
        if (checkbox_bg.isSelected && [self.contentView.text length] > 0) {
            _commentRequest = [[RCPublishPost alloc] init];
            NSMutableDictionary* dics = [NSMutableDictionary dictionaryWithCapacity:5];
            [dics setObject:[NSNumber numberWithInt:_sharetype] forKey:@"source_type"];
            [dics setObject:self.contentView.text forKey:@"comment"];
            
            [dics setObject:[self.currentPrgam objectForKey:@"id"] forKey:@"id"];
            [dics setObject:[self.currentPrgam objectForKey:@"uid"] forKey:@"user_id"];
            RNPublisherViewController* control = (RNPublisherViewController*)self.parentControl;
            _commentRequest.postState.title = [NSString stringWithFormat:NSLocalizedString(@"评论%@给好友:%@", @"评论%@给好友:%@") ,control.accessoryBar.title,self.contentView.text];
            [_commentRequest publishPostWith:nil paramDic:dics withMethod:@"share/addComment"];
        }

    }
    
    
        
    [self.parentControl dismissModalViewControllerAnimated:YES];
}
@end
