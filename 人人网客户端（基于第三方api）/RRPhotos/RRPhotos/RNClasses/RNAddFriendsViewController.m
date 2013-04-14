//
//  RNAddFriendsViewController.m
//  RRSpring
//
//  Created by yi chen on 12-4-12.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNAddFriendsViewController.h"

#define kAlertViewCancelTag 5000


@interface RNAddFriendsViewController ()

@end

@implementation RNAddFriendsViewController

@synthesize bFocusFriend = _bFocusFriend;
@synthesize infoDic = _infoDic;
@synthesize defaultContent = _defaultContent;
- (void)dealloc{
	self.infoDic = nil;
	self.defaultContent  = nil;
	[super dealloc];
}

- (id)initWithInfo:(NSMutableDictionary*)info{
	RCMainUser *mainuser =[RCMainUser getInstance];
    self = [super initWithUserID:mainuser.userId]; //父类的初始化方法
	
	if (self) {
		if (info) { //加入传入的参数
			self.infoDic = info;
			self.bottombar.maxCount = 45;//最大的字数
			self.bottombar.locationButtonEnable = NO; //禁止定位功能
			self.bottombar.photoButtonEnable = NO; //禁止照片功能
			self.bottombar.expressionButtonEnable = NO;//禁止表情
			self.bottombar.atButtonEnable  = NO;  //禁止@好友
//			self.bottombar.infoBgviewEnable = NO; //禁止显示信息栏
			self.bottombar.infoBgviewEnable = YES; 
			self.contentView.delegate = self;
		}
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

- (void)loadView{
	[super loadView];

	self.contentView.returnKeyType = UIReturnKeyNext;
	self.contentView.delegate = self;
	[self.contentView resignFirstResponder]; //键盘问题？暂时这样解决

	RCMainUser *mainUser = [RCMainUser getInstance];
    _defaultContent =  [[NSString alloc]initWithFormat:NSLocalizedString(@"我是%@,想加你为好友", @"我是%@,想加你为好友") , mainUser.userName]; 
	self.contentView.text = self.defaultContent; //设置为默认文案
	[self.bottombar setCurrentTextCount:[self.contentView.text CountWord]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.contentView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.infoDic = nil;
	self.defaultContent = nil;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma -mark UITextViewDelegate

//输入框操作
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    NSLog(@"syp===textViewShouldBeginEditing");
	return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"syp===shouldChangeTextInRange,range=%d,%d,test=%@",range.location,range.length,text);
    if (1 == range.length) {//按下回格键
        return YES;
    }

    return YES;  
}


#pragma -mark RNPublisherAccessoryBarDelegate

/*
 * 点击左边取消按钮
 * 
 */
- (void)publisherAccessoryBarLeftButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
	UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"是否取消加好友", @"是否取消加好友")
													   message:nil
													  delegate:self
											 cancelButtonTitle:NSLocalizedString(@"否", @"否") 
											 otherButtonTitles:NSLocalizedString(@"是", @"是") , nil];
	alertView.tag = kAlertViewCancelTag;
	[alertView show];
	[alertView release];
}

/*
 * 点击右边按钮
 * 
 */
- (void)publisherAccessoryBarRightButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
	NSLog(@"文本长度为:%d",[self.contentView.text CountWord]);
	if ([self.contentView.text CountWord] > 45) {
		
		UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"附言超过45字将无法成功发送", @"附言超过45字将无法成功发送") 
														   message:nil 
														  delegate:nil 
												 cancelButtonTitle:NSLocalizedString(@"确定", @"确定")  
												 otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}else {
		self.publishPost = nil;
		_publishPost = [[RCPublishPost alloc] init];
		
		RCMainUser *mainuserinfo = [RCMainUser getInstance];
		if (self.infoDic) {
			[self.infoDic setObject:mainuserinfo.sessionKey forKey:@"session_key"];
			
			if ([self.contentView.text length] == 0){
				[self.infoDic setObject:_defaultContent forKey:@"content"]; //如果没有输入内容则发送默认文案
			}else {
				[self.infoDic setObject:self.contentView.text forKey:@"content"]; //申请描述

			}
		}
		
		[self.publishPost publishPostWith:nil paramDic:self.infoDic withMethod:@"friends/request"];
		//要用父类来popViewController
//		[self.parentControl.navigationController popViewControllerAnimated: YES];
		[self.parentControl dismissModalViewControllerAnimated:YES];

	}
}


#pragma -mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch (alertView.tag) {
		case kAlertViewCancelTag:{
			if (1 == buttonIndex) { //确定不添加好友
				[self.contentView resignFirstResponder];

//				[self.parentControl.navigationController popViewControllerAnimated: YES];
				[self.parentControl dismissModalViewControllerAnimated:YES];
			}
		}break;
			
		default:
			break;
	}
}

#pragma -mark RNPublisherBottomBtnDelegate
/*
 * 通过语音转换的文本
 * @pram:audioText当前语音转换的文本
 * @pram:isaudio，true表示语音转换的文本，false表示表情获得的文本。
 */
-(void)onUpdateText:(NSString*)text isAudio:(BOOL)isaudio{
	
	self.contentView.text = [NSString stringWithFormat:@"%@%@",self.contentView.text,text];

}

@end
