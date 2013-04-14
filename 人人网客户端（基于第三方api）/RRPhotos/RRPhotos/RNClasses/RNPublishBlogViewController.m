//
//  RNPublishBlogViewController.m
//  RRSpring
//
//  Created by yi chen on 12-4-11.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBlogViewController.h"

//标题栏高度
#define kTitleFieldHeight 30
#define kBlogMaxLength 14000
@interface RNPublishBlogViewController ()

@end

@implementation RNPublishBlogViewController
@synthesize accessoryBar = _accessoryBar;
@synthesize blogTitleField = _blogTitleField;
- (void)dealloc{
	self.accessoryBar =  nil;
	self.blogTitleField = nil;
	
	[super dealloc];
}

- (id)init
{
	RCMainUser *mainuser =[RCMainUser getInstance];
    self = [super initWithUserID:mainuser.userId]; //父类的初始化方法

    if (self) {
        // Custom initialization
		self.bottombar.locationButtonEnable = NO;
		self.bottombar.atButtonEnable = NO;
		self.bottombar.photoButtonEnable = NO;
		self.bottombar.infoBgviewEnable = NO;//禁止显示信息栏

    }
    return self;
}

- (void)loadView{
	[super loadView]; //父类视图加载
   	
	//日志标题栏
	UITextField *titleField = [[UITextField alloc]initWithFrame:
							   CGRectMake(0,0, PHONE_SCREEN_SIZE.width, kTitleFieldHeight)];
	titleField.delegate = self;
	titleField.backgroundColor = RGBCOLOR(230, 230, 230);
	titleField.placeholder = NSLocalizedString(@"主题：", @"主题：");
	titleField.leftViewMode = UITextFieldViewModeAlways;
	titleField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, titleField.height)]; //往左边偏移一点距离
	titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	titleField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	titleField.returnKeyType = UIReturnKeyNext;
	self.blogTitleField = titleField;
	[self.view addSubview:titleField];
	TT_RELEASE_SAFELY(titleField);
	
	//重新设置主输入框的区域
	self.contentView.top =  kTitleFieldHeight; 
    self.contentView.height = self.contentView.height - kTitleFieldHeight;
	self.contentView.returnKeyType = UIReturnKeyNext;
	self.contentView.delegate = self;
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
	
	self.accessoryBar = nil;
	self.blogTitleField = nil;
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma -mark 重写父类的UITextViewDelegate
//输入框操作
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
   // NSLog(@"syp===textViewShouldBeginEditing");

	self.bottombar.expressionButton.enabled = YES;
	
	[self.view layoutIfNeeded];

	if (0 == [textView.text length]) {
		self.accessoryBar.rightButton.enabled = NO;
	}else {
		self.accessoryBar.rightButton.enabled = YES;
	}

    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    //NSLog(@"syp===textViewShouldEndEditing");
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
   // NSLog(@"syp===textViewDidBeginEditing");
}
- (void)textViewDidEndEditing:(UITextView *)textView{
   // NSLog(@"syp===textViewDidEndEditing");
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
   // NSLog(@"syp===shouldChangeTextInRange,range=%d,%d,test=%@",range.location,range.length,text);
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if ([text isEqualToString:@"\n"]) {//按下return键

        return YES;
    }else {
        if ([textView.text length] < 20000 ) {//判断字符个数
            return YES;
        }  
    }
    return NO;
}


#pragma -mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	NSLog(@"cy ------------textFieldShouldBeginEditing");

	self.bottombar.expressionButton.enabled = NO;
	[self.view layoutIfNeeded];
	return YES;
}// return NO to disallow editing.


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	NSLog(@"cy --------------shouldChangeCharactersInRange,range=%d,%d,text=%@",range.location,range.length,string);
	
	if ([string isEqualToString:@"\n"])   
    {  
		NSLog(@"cy--------------按下回车按键");
		[textField resignFirstResponder];//取消第一响应
		[self.contentView becomeFirstResponder];
        return YES;  
    }  
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];  
	
    if (self.blogTitleField == textField)   
    {  
        if ([toBeString length] > 100) {  
            textField.text = [toBeString substringToIndex:100];  
			NSLog(@"cy -----------超过最大字数不能输入了。");
            return NO;  
        }  
    }  
    return YES;  
}// return NO to not change text



#pragma -mark RNPublisherAccessoryBarDelegate

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
	
	if (0 == [self.blogTitleField.text length ]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"请输入日志标题", @"请输入日志标题") 
													   message:nil
													  delegate:nil 
											 cancelButtonTitle:NSLocalizedString(@"确定", @"确定")
											 otherButtonTitles: nil];
		
		[alert show];
		TT_RELEASE_SAFELY(alert);
		
		return;
	}
	
	if (20000 < [self.contentView.text length]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"日志内容超过20000字将无法成功发布", @"日志内容超过20000字将无法成功发布")
													   message:nil
													  delegate:nil 
											 cancelButtonTitle:NSLocalizedString(@"确定", @"确定")
											 otherButtonTitles: nil];
		
		[alert show];
		TT_RELEASE_SAFELY(alert);
		
		return;
	}
	
	RCMainUser *mainuserinfo = [RCMainUser getInstance];
    NSMutableDictionary* dics = [NSMutableDictionary dictionary];
    [dics setObject:mainuserinfo.sessionKey forKey:@"session_key"];

	self.publishPost = nil;
	_publishPost = [[RCPublishPost alloc] init];
	
	[dics setObject:self.blogTitleField.text forKey:@"title"];
	[dics setObject:self.contentView.text forKey:@"content"];
    
    self.publishPost.postState.title = [NSString stringWithFormat:NSLocalizedString(@"发布日志:%@", @"发布日志:%@"),self.blogTitleField.text];
    
	[self.publishPost publishPostWith:nil paramDic:dics withMethod:@"blog/add"];
        
    [self.parentControl dismissModalViewControllerAnimated:YES];
}

#pragma -mark RNPublisherBottomBtnDelegate
/*
 * 通过语音转换的文本
 * @pram:audioText当前语音转换的文本
 * @pram:isaudio，true表示语音转换的文本，false表示表情获得的文本。
 */
-(void)onUpdateText:(NSString*)text isAudio:(BOOL)isaudio{
	
	if ([_firstResponder isEqualToString: @"contentView"]) {
		self.contentView.text = [NSString stringWithFormat:@"%@%@",self.contentView.text,text];
	}else if ([_firstResponder isEqualToString:@"blogTitleField"]){
		self.blogTitleField.text = [NSString stringWithFormat:@"%@%@",self.blogTitleField.text,text];
	}

}


- (void)publisherBottomButtonClick:(UIButton*)currentBotton bottonType:(PublisherBottomButtonType)btnType{
	
	if (_bottombar.audioButtonFocus || _bottombar.expressionButtonFocus) {
		if ([self.contentView isFirstResponder]) {
			_firstResponder = @"contentView";
		}else if ([self.blogTitleField isFirstResponder]){
			_firstResponder = @"blogTitleField";
		}
		
        [self.contentView resignFirstResponder];
		[self.blogTitleField resignFirstResponder];
		
    }else if(_bottombar.audioButtonFocus == NO || _bottombar.expressionButtonFocus == NO){
        if ([_firstResponder isEqualToString: @"contentView"]) {
			[self.contentView becomeFirstResponder];
		}else if ([_firstResponder isEqualToString:@"blogTitleField"]){
			[self.blogTitleField becomeFirstResponder];
		}
		
    }
    
}

@end
