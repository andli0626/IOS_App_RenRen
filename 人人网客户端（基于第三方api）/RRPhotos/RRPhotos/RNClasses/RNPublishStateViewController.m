//
//  RNPublishStateViewController.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-12.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishStateViewController.h"
//#import "RSAppDelegate.h"
@interface RNPublishStateViewController ()

@end

@implementation RNPublishStateViewController
@synthesize currentPrgam=_currentPrgam;

-(void)dealloc{
    [_currentPrgam release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       // self.bottombar.photoButtonEnable = NO;
       // self.bottombar.checkBoxViewEnable = NO;
        self.bottombar.parentViewController = self.parentControl;
        self.currentPrgam = [NSMutableDictionary dictionaryWithCapacity:2];
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
//选择照片回调
-(void)onUpdatePhotoImage:(UIImage*)photoImage photoInfoDic: (NSDictionary * )photoInfoDic{
    [super onUpdatePhotoImage:photoImage photoInfoDic:photoInfoDic];
    if ([photoInfoDic objectForKey:@"id"]) {
        [self.currentPrgam setObject:[photoInfoDic objectForKey:@"id"] forKey:@"aid"];
    }
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
	if ([self.contentView.text length ] > 0 || [self.photo currentImage] != nil ) {
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
    NSMutableDictionary* dics = [NSMutableDictionary dictionary];
    [dics setObject:mainuserinfo.sessionKey forKey:@"session_key"];
    self.publishPost.isLocation = NO;
    if ([self.photo currentImage]) {
        [dics setObject:@"" forKey:@"aid"];
        if ([self.currentPrgam objectForKey:@"aid"]) {
            [dics setObject:[self.currentPrgam objectForKey:@"aid"] forKey:@"aid"];
        }
        [dics setObject:self.contentView.text forKey:@"caption"];
        [dics setObject:@" " forKey:@"place_data"];
        [dics setObject:@"3" forKey:@"upload_type"];
        [dics setObject:@"1" forKey:@"photo_index"];
        [dics setObject:@"0" forKey:@"photo_total"];
        
        if( [self.bottombar getLocationInfo] != nil && [[self.bottombar getLocationInfo] count] > 0 ){
            NSMutableDictionary *locationinfo = [self.bottombar getLocationInfo];
            [dics setObject:[locationinfo JSONString] forKey:@"place_data"];
            self.publishPost.isLocation = YES;
        }
        self.publishPost.postState.title = [NSString stringWithFormat:NSLocalizedString(@"上传图片:%@", @"上传图片:%@"),self.contentView.text];
        self.publishPost.postState.thumbnails = [UIImage scaleImage:[self.photo currentImage] scaleToSize:CGSizeMake(35, 35)];
        [self.publishPost publishPostWith:[self.photo currentImage] paramDic:dics withMethod:@"photos/uploadbin"];
        
    }else
    {
        if( [self.bottombar getLocationInfo] != nil && [self.bottombar.locationInfo count]>0){
            NSMutableDictionary *locationinfo = [self.bottombar getLocationInfo];
            [dics setObject:[locationinfo JSONString] forKey:@"place_data"];
            self.publishPost.isLocation = YES;
        }
        [dics setObject:self.contentView.text forKey:@"status"];
        self.publishPost.postState.title = [NSString stringWithFormat:NSLocalizedString(@"发送状态:%@", @"发送状态:%@"),self.contentView.text];
        [self.publishPost publishPostWith:nil paramDic:dics withMethod:@"status/set"];
        
    }
    
    [self.parentControl dismissModalViewControllerAnimated:YES];
    
}
@end
