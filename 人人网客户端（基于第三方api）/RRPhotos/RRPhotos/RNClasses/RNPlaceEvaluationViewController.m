//
//  RNPlaceEvaluationViewController.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-21.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPlaceEvaluationViewController.h"

@interface RNPlaceEvaluationViewController ()

@end

@implementation RNPlaceEvaluationViewController
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
        self.bottombar.locationButtonEnable = NO;
        self.bottombar.checkBoxViewEnable = YES;
    
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
	选择照片回调
 */
-(void)onUpdatePhotoImage:(UIImage*)photoImage photoInfoDic: (NSDictionary * )photoInfoDic{
    [super onUpdatePhotoImage:photoImage photoInfoDic:photoInfoDic];
    if ([photoInfoDic objectForKey:@"id"]) { //照片要上传的相册id
        [self.currentPrgam setObject:[photoInfoDic objectForKey:@"id"] forKey:@"aid"];
    }
}

/*
 * 点击左边取消按钮
 * 
 */
- (void)publisherAccessoryBarLeftButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    [self.parentControl dismissModalViewControllerAnimated:YES];
}
/*
 * 点击右边按钮
 * 
 */
- (void)publisherAccessoryBarRightButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar{
    
	NSMutableDictionary *dics = [NSMutableDictionary dictionaryWithDictionary:self.currentPrgam];

	//////////////////////////////////////////////////////////////
	
	RCMainUser *mainuserinfo = [RCMainUser getInstance];
    [dics setObject:mainuserinfo.sessionKey forKey:@"session_key"];
    self.publishPost.isLocation = NO;
    if ([self.photo currentImage]) { //如果有照片的话就是在当前的地点上传照片
        [dics setObject:@"" forKey:@"aid"];
        if ([self.currentPrgam objectForKey:@"aid"]) {
            [dics setObject:[self.currentPrgam objectForKey:@"aid"] forKey:@"aid"];
        }
        [dics setObject:self.contentView.text forKey:@"caption"];
        [dics setObject:@"3" forKey:@"upload_type"];
        [dics setObject:@"1" forKey:@"photo_index"];
        [dics setObject:@"0" forKey:@"photo_total"];
		//地点信息要转化为json数据
		[dics setObject:[[self.currentPrgam objectForKey:@"place_data"] JSONString] forKey:@"place_data"];
		
		self.publishPost.postState.title = [NSString stringWithFormat:NSLocalizedString(@"上传图片:%@", @"上传图片:%@"),self.contentView.text];
        self.publishPost.postState.thumbnails = [UIImage scaleImage:[self.photo currentImage] scaleToSize:CGSizeMake(35, 35)];
        [self.publishPost publishPostWith:[self.photo currentImage] paramDic:dics withMethod:@"photos/uploadbin"];
        
    }else{

		[dics setObject:self.contentView.text forKey:@"content"];
		[dics setObject:[NSNumber numberWithInt:1] forKey:@"privacy"];
		
		self.publishPost.postState.title = [NSString stringWithFormat:NSLocalizedString(@"对%@评价:%@", @"对%@评价:%@"),
											[self.currentPrgam objectForKey:@"place_name"],self.contentView.text];
		[self.publishPost publishPostWith:nil paramDic:dics withMethod:@"place/addEvaluation"];
    }
    
    [self.parentControl dismissModalViewControllerAnimated:YES];
    
}
@end
