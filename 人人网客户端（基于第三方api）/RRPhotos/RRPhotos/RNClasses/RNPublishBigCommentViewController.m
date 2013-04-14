//
//  RNPublishBigCommentViewController.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-26.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBigCommentViewController.h"
#import "RNEditPhotoViewController.h"

#define ATFASTVIEW_TOP 60.0f
#define ATFASTVIEW_HEIGHT 150.0F
//检测@时候用到与检测的最大长度
#define CHICKATSTR_LENGTH 8   

@implementation RNPublishBigCommentViewController
@synthesize contentView = _contentView;
@synthesize bottombar=_bottombar;
@synthesize photo=_photo;
@synthesize publishPost=_publishPost;
@synthesize requestDelegate=_requestDelegate;
@synthesize parentControl=_parentControl;

-(void)dealloc{

    [_contentView release];
    [_bottombar release];
    RL_RELEASE_SAFELY(_publishPost);
    RL_RELEASE_SAFELY(_fasrAtview);
    [super dealloc];
}
-(id)initWithUserID:(NSNumber*)userId{
    self = [super init];
    if (self) {

    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _bottombar = [[RNPublisherBottomBar alloc] init];
        _photo = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 94, 94)];
        [_photo addTarget:self action:@selector(photoClick:) forControlEvents:UIControlEventTouchDown];
        
        //_publishPost=[RCPublishPost alloc];
        _publishPost = [[RCPublishPost alloc] init];
        NSInteger textview_h = PHONE_SCREEN_SIZE.height
        -PUBLISH_ENGISH_KEYBOARD_TOP-PUBLISH_BOTTOM_HEIGHT-PUBLISH_BOTTOM_INFO_HRIGHT;
        UITextView *contentView = [[UITextView alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               PHONE_SCREEN_SIZE.width,
                                                                               textview_h)];
        contentView.font = [UIFont boldSystemFontOfSize:18];
        contentView.dataDetectorTypes=UIDataDetectorTypeAddress;
        contentView.delegate = self;
        contentView.returnKeyType=UIReturnKeyDone;
        self.contentView = contentView;
        RL_RELEASE_SAFELY(contentView);
        _fasrAtview = [[RNFastAtFriendView alloc] initWithFrame:CGRectMake(0, ATFASTVIEW_TOP, PHONE_SCREEN_SIZE.width, ATFASTVIEW_HEIGHT)];
        _fasrAtview.deldgate = self;
    }
    return self;
}
-(void)showAlertWithMsg:(NSString*)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"确定", @"确定") 
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}
-(void)photoClick:(UIButton*)btn{
    UIActionSheet *sheet = nil; 
    sheet = [[UIActionSheet alloc] initWithTitle:nil 
                                        delegate:self  
                               cancelButtonTitle:nil 
                          destructiveButtonTitle:nil 
                               otherButtonTitles:nil];
    [sheet addButtonWithTitle:NSLocalizedString(@"重选照片", @"重选照片")];
    [sheet addButtonWithTitle:NSLocalizedString(@"编辑照片", @"编辑照片")];
    [sheet addButtonWithTitle:NSLocalizedString(@"删除照片", @"删除照片")]; 
    [sheet addButtonWithTitle:NSLocalizedString(@"取消", @"取消")]; 
    sheet.destructiveButtonIndex = 3;
    [sheet showFromRect:self.view.bounds inView:self.view animated:YES]; 
    [sheet release]; 

}
-(void)setSelectPhoto:(UIImage*)imagedata{
    CGRect textViewFram = self.contentView.frame;
    textViewFram.size.width = PHONE_SCREEN_SIZE.width - 100;
    self.contentView.frame = textViewFram;
    
    CGRect photoimagefrmae = self.photo.frame;
    photoimagefrmae.origin.x = (textViewFram.size.width + PHONE_SCREEN_SIZE.width-photoimagefrmae.size.width)/2;
    photoimagefrmae.origin.y = 0;
    self.photo.frame = photoimagefrmae;
    [self.photo setImage:imagedata forState:UIControlStateNormal];
    [self.view addSubview:self.photo];
}
/**
 * 照片编辑完成回调
 */
- (void)editPhotoFinished:(UIImage *) imageEdited photoInfoDic: (NSDictionary * )photoInfoDic{
    [self setSelectPhoto:imageEdited];
}
-(void)delSelectPhoto{
    [self.photo setImage:nil forState:UIControlStateNormal];
    [self.photo removeFromSuperview];
    CGRect textViewFram = self.contentView.frame;
    textViewFram.size.width = PHONE_SCREEN_SIZE.width;
    self.contentView.frame = textViewFram;
    
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //重新选择
        [self.bottombar btnChange:EPublishBottomPhotoType];
    }else if (buttonIndex == 1){
        //
        RNEditPhotoViewController *_photoedit = [[RNEditPhotoViewController alloc] init];
        [_photoedit loadImageToEdit:[self.photo currentImage]];
        _photoedit.delegate = self;
        [_parentControl presentModalViewController:_photoedit animated:YES];
        [_photoedit release];
    }else if(buttonIndex == 2){
        //取消
        [self delSelectPhoto];
        
    }else {
        
    }
    
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [self.view addSubview:self.contentView];
    _fasrAtview.parentview = self.view;
    //高度加1是为了增加一个分割线
    self.bottombar.frame =  CGRectMake(0, 
                                       self.contentView.frame.size.height,
                                       PHONE_SCREEN_SIZE.width,
                                       PUBLISH_BOTTOM_HEIGHT+PUBLISH_BOTTOM_INFO_HRIGHT+1);
    self.bottombar.btnDelegate = self;
    
}

- (void)setParentControl:(UIViewController *)parentControl{
	_parentControl = parentControl;
	//将parentViewController传给bottomBar
	self.bottombar.parentViewController = _parentControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:_bottombar];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1]];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                          selector:@selector(keyboardWillShow:) 
                                          name:UIKeyboardWillShowNotification 
                                          object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                          selector:@selector(keyboardWillHide:) 
                                          name:UIKeyboardWillHideNotification 
                                          object:nil];
    
    [self.contentView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//    self.contentView = nil;
//    self.bottombar = nil;
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//键盘变化位置调整
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:nil context:NULL]; 
    [UIView setAnimationDuration:animationDuration];
    CGRect textframe=self.contentView.frame;
    textframe.size.height = self.view.frame.size.height
                            -keyboardRect.size.height-_bottombar.frame.size.height;
    self.contentView.frame = textframe;
    CGRect bottombarframe=_bottombar.frame;
    bottombarframe.origin.y = textframe.size.height;
    _bottombar.frame=bottombarframe;
    //快速@好友大小调整
    CGRect atfastframe=_fasrAtview.frame;
    atfastframe.size.height = self.view.frame.size.height - ATFASTVIEW_TOP - keyboardRect.size.height;
    _fasrAtview.frame=atfastframe;
    [UIView commitAnimations];
    [_bottombar resetAllState];    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    //恢复初始位置
    [UIView beginAnimations:nil context:NULL]; 
    [UIView setAnimationDuration:animationDuration];
    CGRect textframe=self.contentView.frame;
    textframe.size.height = self.view.frame.size.height-_bottombar.frame.size.height-PUBLISH_ENGISH_KEYBOARD_TOP;
    self.contentView.frame = textframe;
    CGRect bottombarframe=_bottombar.frame;
    bottombarframe.origin.y = textframe.size.height;
    _bottombar.frame=bottombarframe;
    //快速@好友大小调整
    CGRect atfastframe=_fasrAtview.frame;
    atfastframe.size.height = self.view.frame.size.height - ATFASTVIEW_TOP;
    _fasrAtview.frame=atfastframe;
    
    [UIView commitAnimations];
}
//输入框底部按钮区点击事件处理
- (void)publisherBottomButtonClick:(UIButton*)currentBotton bottonType:(PublisherBottomButtonType)btnType{

  if (_bottombar.audioButtonFocus || _bottombar.expressionButtonFocus) {
        [self.contentView resignFirstResponder];
    }else if(_bottombar.audioButtonFocus == NO || _bottombar.expressionButtonFocus == NO){
        [self.contentView becomeFirstResponder];
    }
    
}
//语音或者表情输入文本回调
-(void)onUpdateText:(NSString*)text isAudio:(BOOL)isaudio{
   
    self.contentView.text = [NSString stringWithFormat:@"%@%@",self.contentView.text,text];
    [_bottombar setCurrentTextCount:[self.contentView.text CountWord]];
}
//选择照片回调
-(void)onUpdatePhotoImage:(UIImage*)photoImage photoInfoDic: (NSDictionary * )photoInfoDic{
    [self setSelectPhoto:photoImage];
}
//快速@好友回调
-(void)didSelectUser:(NSString*)atuserinfo{
    
    NSRange result =  [self.contentView.text rangeOfString:@"@" options:NSBackwardsSearch];
    NSString *currenttext = [NSString stringWithString:[self.contentView.text substringToIndex:result.location]]; 
    self.contentView.text = [NSString stringWithFormat:@"%@%@",currenttext,atuserinfo];
    [_bottombar setCurrentTextCount:[self.contentView.text CountWord]];
}
//输入框操作
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
  //  NSLog(@"syp===textViewShouldBeginEditing");
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
  //  NSLog(@"syp===textViewShouldEndEditing");
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
  //  NSLog(@"syp===textViewDidBeginEditing");
}
- (void)textViewDidEndEditing:(UITextView *)textView{
  //  NSLog(@"syp===textViewDidEndEditing");
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
   // NSLog(@"syp===shouldChangeTextInRange,range=%d,%d,test=%@",range.location,range.length,text);
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if ([text isEqualToString:@"\n"]) {//按下return键
        //这里隐藏键盘，不做任何处理
        [textView resignFirstResponder];
        return NO;
    }else {
        if ([textView.text length] < 240) {//判断字符个数
            //return YES;
        }  
    }
    return YES;
}
-(void)isShowAtFastview:(NSString*)text{
    if (!text ||[text length] <=0 || self.bottombar.atButtonEnable == NO) {
        return;
    }
    NSString* checkstr = [NSString stringWithString:text];
    NSInteger strLength = [checkstr length]; 
    NSRange range ;
    range.length = CHICKATSTR_LENGTH > strLength ? strLength:CHICKATSTR_LENGTH;
    range.location = strLength-CHICKATSTR_LENGTH > 0 ? strLength-CHICKATSTR_LENGTH:0;
    NSRange result =  [checkstr rangeOfString:@"@" options:NSBackwardsSearch range:range];
    if (result.length != 0) {
        NSRange rang = NSMakeRange(result.location+1,strLength-result.location-1);
        if (rang.length>0 && (range.location + range.length)<=strLength) {
            NSString * strRang = [checkstr substringWithRange:rang];
            [_fasrAtview showFastAtFriendView:CGPointMake(0, 0) searchText:strRang];
            return;
        }
    }
    [_fasrAtview hideFastAtFriendView];    
}
- (void)textViewDidChange:(UITextView *)textView{
    NSLog(@"syp===textViewDidChange");
    [_bottombar setCurrentTextCount:[textView.text CountWord]];
    [self isShowAtFastview:textView.text];
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    NSLog(@"syp===textViewDidChangeSelection");
    
}
- (void)publishPostWith:(UIImage *)photoImage
               paramDic:(NSDictionary *)paramDic
             withMethod:(NSString*)method{
    
    [_publishPost publishPostWith:photoImage paramDic:paramDic withMethod:method];
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
    
}
@end









