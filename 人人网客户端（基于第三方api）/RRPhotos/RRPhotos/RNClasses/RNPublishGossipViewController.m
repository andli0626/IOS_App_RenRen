//
//  RNPublishGossipViewController.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-21.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishGossipViewController.h"

@interface RNPublishGossipViewController ()

@end

@implementation RNPublishGossipViewController
@synthesize currentPrgam=_currentPrgam;

-(void)dealloc{
    [_currentPrgam release];
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
        self.bottombar.photoButtonEnable = NO;
        self.bottombar.atButtonEnable = NO;
        self.bottombar.locationButtonEnable = NO;
        self.bottombar.checkBoxViewEnable = YES;
        [self.bottombar setCheckInfo:NSLocalizedString(@"悄悄话", @"悄悄话")];
        if ([self.currentPrgam objectForKey:@"friend_name"] == nil) {
            [self.currentPrgam setObject:NSLocalizedString(@"未知用户", @"未知用户") forKey:@"friend_name"];
        }
       // [self.currentPrgam setObject:[NSNumber numberWithLong:76922144] forKey:@"userId"];
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
	if ([self.contentView.text length ] > 0) {
		UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"是否取消发布", @"是否取消发布") 
														   message:nil
														  delegate:self 
												 cancelButtonTitle:NSLocalizedString(@"取消", @"取消")
												 otherButtonTitles:NSLocalizedString(@"确定", @"确定"), nil];
		[alertView show];
		[alertView release];
	}else { //内容为空，直接pop
        [self.parentControl dismissModalViewControllerAnimated:YES];
	}
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
        [self showAlertWithMsg:NSLocalizedString(@"字数超出限制哦亲!", @"字数超出限制哦亲!")];
        return;
    }
    RCMainUser *mainuserinfo = [RCMainUser getInstance];
    NSMutableDictionary* dics = [NSMutableDictionary dictionaryWithDictionary:self.currentPrgam];
    [dics setObject:mainuserinfo.sessionKey forKey:@"session_key"];
    if ([self.bottombar getCheckState]) {
        [dics setObject:[NSNumber numberWithInt:1] forKey:@"isWhisper"];
    }
    self.publishPost.postState.title = [NSString stringWithFormat:NSLocalizedString(@"给%@留言:%@", @"给%@留言:%@"),[self getValueBykey:@"friend_name" isDeleate:YES],self.contentView.text];
    [dics setObject:self.contentView.text forKey:@"content"];
    [self.publishPost publishPostWith:nil paramDic:dics withMethod:@"gossip/postGossip"];
    [self.parentControl dismissModalViewControllerAnimated:YES];
    
}
@end
