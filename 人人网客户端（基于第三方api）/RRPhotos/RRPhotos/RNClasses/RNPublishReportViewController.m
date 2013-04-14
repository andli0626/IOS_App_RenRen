//
//  RNPublishReportViewController.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-19.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishReportViewController.h"

@interface RNPublishReportViewController ()

@end

@implementation RNPublishReportViewController
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
        self.bottombar.checkBoxViewEnable = YES;
        
        
        
        [self.bottombar addLocationInfo:[self.currentPrgam objectForKey:@"publisherpoilist"]];
        
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
- (void)loadView
{
    [super loadView];


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
    RCMainUser *mainuserinfo = [RCMainUser getInstance];
    NSMutableDictionary* dics = [NSMutableDictionary dictionary];
    [dics setObject:mainuserinfo.sessionKey forKey:@"session_key"];
    
    if (!self.bottombar.locationInfo || [self.bottombar.locationInfo count]<=0) {
        [self showAlertWithMsg:NSLocalizedString(@"没有定位信息不能报道哦亲!", @"没有定位信息不能报道哦亲!")];
        return;
    }
    if (self.bottombar.currentCount > self.bottombar.maxCount) {
        [self showAlertWithMsg:NSLocalizedString(@"字数超出限制哦亲!", @"字数超出限制哦亲!")];
        return;
    }
    self.publishPost.isLocation = YES;
    [dics setObject:[self.bottombar.locationInfo objectForKey:@"place_id"] forKey:@"pid"];
    [dics setObject:self.contentView.text forKey:@"status"];
    [dics setObject:[NSNumber numberWithInt:2] forKey:@"privacy"];
    [dics setObject:[self.bottombar.locationInfo objectForKey:@"gps_longitude"] forKey:@"lon_gps"];
    [dics setObject:[self.bottombar.locationInfo objectForKey:@"gps_latitude"] forKey:@"lat_gps"];
    [dics setObject:[self.bottombar.locationInfo objectForKey:@"place_name"] forKey:@"poi_name"];

    self.publishPost.postState.title = [NSString stringWithFormat:NSLocalizedString(@"在%@报道:%@", @"在%@报道:%@"),[self.currentPrgam objectForKey:@"place_name"],self.contentView.text];
    [self.publishPost publishPostWith:nil paramDic:dics withMethod:@"place/checkin"];
    [self.parentControl dismissModalViewControllerAnimated:YES];
    
}

@end
