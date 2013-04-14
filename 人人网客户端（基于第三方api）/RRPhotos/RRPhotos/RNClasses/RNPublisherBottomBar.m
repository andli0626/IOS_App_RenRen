//
//  RNPublisherBottomBar.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-22.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublisherBottomBar.h"
#include <objc/runtime.h>
#import "RNEmotionView.h"

#import "RNPublishBigCommentViewController.h"


#import "AppDelegate.h"


//此appid为您所申请,请勿随意修改
#define APPID @"4efd1b97"
#define ENGINE_URL @"http://dev.voicecloud.cn:1028/index.htm"
#define H_CONTROL_ORIGIN CGPointMake(20, 70)

typedef enum _IsrType
{
IsrText = 0,		// 转写
IsrKeyword,			// 关键字识别
IsrUploadKeyword	// 关键字上传
}IsrType;

@interface RNPublisherBottomBar(Private)

- (void)getLocationInfoFromCache;

@end

@implementation RNPublisherBottomBar

@synthesize parentViewController=_parentViewController;
@synthesize uid=_uid;
@synthesize canAtFriend=_canAtFriend;


@synthesize audioButton=_audioButton;
@synthesize locationButton=_locationButton;
@synthesize photoButton=_photoButton;
@synthesize atButton=_atButton;
@synthesize expressionButton=_expressionButton;
@synthesize statisticsLable = _statisticsLable;
@synthesize buttonBgView=_buttonBgView;
@synthesize infoBgView=_infoBgView;
@synthesize checkBoxView=_checkBoxView;


@synthesize audioButtonEnable=_audioButtonEnable;
@synthesize locationButtonEnable=_locationButtonEnable;
@synthesize photoButtonEnable=_photoButtonEnable;
@synthesize atButtonEnable=_atButtonEnable;
@synthesize expressionButtonEnable=_expressionButtonEnable;
@synthesize infoBgviewEnable=_infoBgviewEnable;
@synthesize checkBoxViewEnable = _checkBoxViewEnable;

@synthesize audioButtonFocus=_audioButtonFocus;
@synthesize expressionButtonFocus=_expressionButtonFocus;
//@synthesize locationButtonFocus=_locationButtonFocus;

@synthesize maxCount=_maxCount;
@synthesize currentCount=_currentCount;
@synthesize audioTimer=_audioTimer;

@synthesize btnDelegate=_btnDelegate;

@synthesize isLocationSucess=_isLocationSucess;
@synthesize locationInfo=_locationInfo;



-(void)dealloc{
    [super dealloc];
    [_expressionButton release];
    [_atButton release];
    [_photoButton release];
    [_locationButton release];
    [_audioButton release];
    [_statisticsLable release];
    [_locationView release];
    [_infoBgView release]; 
    [_buttonBgView release];
    [_checkBoxView release];
    [_locationInfo release];
    [_uid release];
    if (_pictureInfo) {
        [_pictureInfo release];
        _pictureInfo = nil;
    }
    if (_iFlyRecognizeControl) {
        [_iFlyRecognizeControl release];
    }
    if (_iphotocon) {
        [_iphotocon release];
        _iphotocon = nil;
    }
    if (_audioTimer) {
        [_audioTimer release];
        _audioTimer = nil;
    }
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
-(void)layoutLocationWithName:(NSString*)locationName{
    
    UIButton *locationBtn = (UIButton*)[_locationView viewWithTag:10001];
    UIImageView *_arrowIcon = (UIImageView*)[locationBtn viewWithTag:10002];
    [locationBtn setTitle:locationName forState:UIControlStateNormal];
    CGRect btnframe = locationBtn.frame;
    CGSize locationautosize = [locationBtn.titleLabel.text sizeWithFont:locationBtn.titleLabel.font];
    if (locationautosize.width > PHONE_SCREEN_SIZE.width-120) {
        locationautosize.width = PHONE_SCREEN_SIZE.width-120;
    }
    btnframe.size.width = locationautosize.width+_arrowIcon.frame.size.width;
    locationBtn.frame = btnframe;
    CGRect iconframe = _arrowIcon.frame; 
    iconframe.origin.x = btnframe.origin.x +locationautosize.width-10;
    iconframe.origin.y = (btnframe.size.height - iconframe.size.height)/2;
    _arrowIcon.frame = iconframe;
}

-(void)initView{
    //内部成员变量
    self.canAtFriend = YES;
    self.isLocationSucess = NO;
    _currentCount = 0;
    _maxCount = 240;
    _locationInfo = [[NSMutableDictionary alloc] init];
    _uid = [[NSNumber alloc] init];
    
    //定位信息
    UIView *_spaceLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PHONE_SCREEN_SIZE.width, 1)];
    [_spaceLine setBackgroundColor:[UIColor colorWithRed:0.74 green:0.74 blue:0.74 alpha:1]];
    [self addSubview:_spaceLine];
    [_spaceLine release];
    //增加信息区
    _infoBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, 
                                                                   PHONE_SCREEN_SIZE.width, 
                                                                   PUBLISH_BOTTOM_INFO_HRIGHT)];
    [_infoBgView setBackgroundColor:[UIColor whiteColor]];
    //定位信息
    _locationView = [[UIView alloc] initWithFrame:CGRectMake(3, 4, 
                                                             PHONE_SCREEN_SIZE.width-100, 
                                                             PUBLISH_BOTTOM_INFO_HRIGHT-8)];
    
    UIButton *_icon =  [UIButton buttonWithType:UIButtonTypeCustom];
    [_icon setBackgroundImage:[[RCResManager getInstance] imageForKey:@"publish_checkbox"] forState:UIControlStateNormal];
    [_icon setImage:[[RCResManager getInstance] imageForKey:@"publish_haslocated"] forState:UIControlStateNormal];
    [_icon setFrame:CGRectMake(0, 0, PUBLISH_BOTTOM_INFO_HRIGHT-8, PUBLISH_BOTTOM_INFO_HRIGHT-8)];
    [_locationView addSubview:_icon];
    [_infoBgView addSubview:_locationView];
    //下拉箭头
    UIImageView *_listarrowIcon = [[UIImageView alloc] initWithImage:[[RCResManager getInstance] imageForKey:@"publish_listarrow"]];
    _listarrowIcon.tag = 10002;
    UIButton *_currentLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    [_currentLocation setFrame:CGRectMake(PUBLISH_BOTTOM_INFO_HRIGHT-8, 0, 80, PUBLISH_BOTTOM_INFO_HRIGHT-8)];
    _currentLocation.tag = 10001;
    [_currentLocation addTarget:self action:@selector(locationButtonClick:) forControlEvents:UIControlEventTouchDown];
    [_currentLocation addSubview:_listarrowIcon];
    [_locationView addSubview:_currentLocation];
    _currentLocation.titleLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:18.0];
    [_currentLocation setTitleColor:[UIColor colorWithRed:0.42 green:0.52 blue:0.62 alpha:1] 
                           forState:UIControlStateNormal];
    
    [_currentLocation.titleLabel setTextAlignment:UITextAlignmentLeft];
    [self layoutLocationWithName:NSLocalizedString(@"正在定位...", @"正在定位...")];
    _locationView.hidden = YES;
    
    //字数统计信息
    _statisticsLable = [[UILabel alloc] initWithFrame:CGRectMake(PHONE_SCREEN_SIZE.width-100, 
                                                                 (PUBLISH_BOTTOM_INFO_HRIGHT-20)/2, 
                                                                 80, 
                                                                 20)];
    _statisticsLable.font = [UIFont fontWithName:LIGHT_HEITI_FONT size:16.0];
    _statisticsLable.textColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1];
    _statisticsLable.text = [NSString stringWithFormat:@"%d/%d",_currentCount,_maxCount];
    [_statisticsLable setTextAlignment:UITextAlignmentRight];
    [_infoBgView addSubview:_statisticsLable];
    [self addSubview:_infoBgView];
           
    //存放button按钮的背景view
    _buttonBgView = [[UIView alloc] initWithFrame:CGRectMake(0, PUBLISH_BOTTOM_INFO_HRIGHT +1, PHONE_SCREEN_SIZE.width, PUBLISH_BOTTOM_HEIGHT)];
    [_buttonBgView setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1]];
    
    
    //checkbox 
    _checkBoxView = [[UIView alloc] initWithFrame:CGRectMake(3, 4, 
                                                             100, 
                                                             PUBLISH_BOTTOM_HEIGHT-8)];
    UIButton *checkbox_bg = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkbox_bg setImage:[[RCResManager getInstance] imageForKey:@"publish_checkbox"] forState:UIControlStateNormal];
    [checkbox_bg setImage:[[RCResManager getInstance] imageForKey:@"publish_checkbox_sel"] forState:UIControlStateSelected];
    [checkbox_bg addTarget:self action:@selector(checkBoxClick:) forControlEvents:UIControlEventTouchDown];
    checkbox_bg.tag = 10003;
    [_checkBoxView addSubview:checkbox_bg];
    
    UILabel *checkboxInfo = [[UILabel alloc] initWithFrame:CGRectMake(PUBLISH_BOTTOM_HEIGHT-8, 4, 80, PUBLISH_BOTTOM_HEIGHT-8)];
    checkboxInfo.tag = 10004;
    checkboxInfo.font = [UIFont fontWithName:MED_HEITI_FONT size:12.0];
    checkboxInfo.textColor = [UIColor colorWithRed:0.42 green:0.52 blue:0.62 alpha:1];
    [checkboxInfo setBackgroundColor:[UIColor clearColor]];
    checkboxInfo.text = NSLocalizedString(@"悄悄话", @"悄悄话");
    [_checkBoxView addSubview:checkboxInfo];
    [checkboxInfo release];
    [_buttonBgView addSubview:_checkBoxView];
    
    //语音按钮
    _audioButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _audioButton.tag = EPublishBottomAoduType;
    [_audioButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    
    [_audioButton setImage:[[RCResManager getInstance] imageForKey:@"publish_audio"] forState:UIControlStateNormal];
    [_audioButton setImage:[[RCResManager getInstance] imageForKey:@"publish_audio_sel"] forState:UIControlStateHighlighted];
    [_audioButton setImage:[[RCResManager getInstance] imageForKey:@"publish_audio_sel"] forState:UIControlStateSelected];
    [_buttonBgView addSubview:_audioButton];
    
    //定位按钮
    _locationButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _locationButton.tag = EPublishBottomLocationType;
    [_locationButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    [_locationButton setImage:[[RCResManager getInstance] imageForKey:@"publish_location"] forState:UIControlStateNormal];
    [_locationButton setImage:[[RCResManager getInstance] imageForKey:@"publish_location_sel"] forState:UIControlStateHighlighted];
    [_locationButton setImage:[[RCResManager getInstance] imageForKey:@"publish_location_sel"] forState:UIControlStateSelected];
    [_buttonBgView addSubview:_locationButton];
    
    //照片按钮
    _photoButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _photoButton.tag = EPublishBottomPhotoType;
    [_photoButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    [_photoButton setImage:[[RCResManager getInstance] imageForKey:@"publish_picture"] forState:UIControlStateNormal];
    [_photoButton setImage:[[RCResManager getInstance] imageForKey:@"publish_picture_sel"] forState:UIControlStateHighlighted];
    [_buttonBgView addSubview:_photoButton];
    
    //@按钮
    _atButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _atButton.tag = EPublishBottomAtType;
    [_atButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    [_atButton setImage:[[RCResManager getInstance] imageForKey:@"publish_at"] forState:UIControlStateNormal];
    [_atButton setImage:[[RCResManager getInstance] imageForKey:@"publish_at_sel"] forState:UIControlStateHighlighted];
    [_buttonBgView addSubview:_atButton];
    
    //表情按钮
    _expressionButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _expressionButton.tag = EPublishBottomEmojeType;
    [_expressionButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    [_expressionButton setImage:[[RCResManager getInstance] imageForKey:@"publish_expression"] forState:UIControlStateNormal];
    [_expressionButton setImage:[[RCResManager getInstance] imageForKey:@"publish_expression_sel"] forState:UIControlStateHighlighted];
    [_expressionButton setImage:[[RCResManager getInstance] imageForKey:@"publish_expression_sel"] forState:UIControlStateSelected];
    [_buttonBgView addSubview:_expressionButton];
    [self addSubview:_buttonBgView];
   

    
    //默认全部显示
    self.audioButtonEnable = YES;
    self.locationButtonEnable = YES;
    self.photoButtonEnable = YES;
    self.atButtonEnable = YES;
    self.expressionButtonEnable = YES;
    self.infoBgviewEnable =YES;
    _isWhisper=NO;
    //默认不展开功能区
    self.audioButtonFocus = NO;
    self.expressionButtonFocus = NO;
    //默认不显示checkbox
    self.checkBoxViewEnable = NO;
    //功能扩展区只创建不显示
    _bottomExtView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, PHONE_SCREEN_SIZE.width, PUBLISH_ENGISH_KEYBOARD_TOP)];
    [_bottomExtView setBackgroundColor:[UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1]];
    
    //外部数据
    _iphotocon = [[RNPickPhotoHelper alloc] init];
}
-(id)init{
    self = [super init];
    if (self) {
       // [self initView];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}
- (void)layoutSubviews{
    NSInteger width = self.frame.size.width;
    NSInteger height = PUBLISH_BOTTOM_HEIGHT;
    NSInteger current_X = width;
    NSInteger picSpace = 13;
    NSInteger right_space = 8;
    BOOL isTheLast=YES;
    //右对齐所以从右开始布局
    if (self.expressionButtonEnable) {
        CGSize expressionButtonSize = [[_expressionButton currentImage] size];
        current_X = current_X - right_space - expressionButtonSize.width;
        isTheLast = NO;
        CGRect backbuttonFrame = CGRectMake(current_X,
                                            (height - expressionButtonSize.height)/2,
                                            expressionButtonSize.width,
                                            expressionButtonSize.height);
        _expressionButton.frame = CGRectIntegral(backbuttonFrame);
        
    }
    if (self.atButtonEnable) {
        CGSize atButtonSize = [[_atButton currentImage] size];
        if (isTheLast) {
            isTheLast=NO;
            current_X = current_X - right_space - atButtonSize.width;
        }else {
            current_X = current_X - picSpace - atButtonSize.width;
        }
        
        CGRect backbuttonFrame = CGRectMake(current_X,
                                            (height - atButtonSize.height)/2,
                                            atButtonSize.width,
                                            atButtonSize.height);
        _atButton.frame = CGRectIntegral(backbuttonFrame);
        
    }
    if (self.photoButtonEnable) {
        CGSize photoButtonSize = [[_photoButton currentImage] size];
        if (isTheLast) {
            isTheLast=NO;
            current_X = current_X - right_space - photoButtonSize.width;
        }else {
            current_X = current_X - picSpace - photoButtonSize.width;
        }
        CGRect backbuttonFrame = CGRectMake(current_X,
                                            (height - photoButtonSize.height)/2,
                                            photoButtonSize.width,
                                            photoButtonSize.height);
        _photoButton.frame = CGRectIntegral(backbuttonFrame);
        
    }
    
    if (self.locationButtonEnable) {
        CGSize localButtonSize = [[_locationButton currentImage] size];
        if (isTheLast) {
            isTheLast=NO;
            current_X = current_X - right_space - localButtonSize.width;
        }else {
            current_X = current_X - picSpace - localButtonSize.width;
        }
        CGRect backbuttonFrame = CGRectMake(current_X,
                                            (height - localButtonSize.height)/2,
                                            localButtonSize.width,
                                            localButtonSize.height);
        _locationButton.frame = CGRectIntegral(backbuttonFrame);
        if (self.locationButton.selected) {
            _locationView.hidden = NO;
        }else {
             _locationView.hidden = YES;
        }
    }else {
        _locationView.hidden = YES;
    }
    
    if (self.audioButtonEnable) {
        CGSize audioButtonSize = [[_audioButton currentImage] size];
        if (isTheLast) {
            isTheLast=NO;
            current_X = current_X - right_space - audioButtonSize.width;
        }else {
            current_X = current_X - picSpace - audioButtonSize.width;
        }
        CGRect backbuttonFrame = CGRectMake(current_X,
                                            (height - audioButtonSize.height)/2,
                                            audioButtonSize.width,
                                            audioButtonSize.height);
        _audioButton.frame = CGRectIntegral(backbuttonFrame);
        
    }
    //布局字数统计
    CGRect iframe = _statisticsLable.frame;
    CGSize usernameautosize = [_statisticsLable.text sizeWithFont:_statisticsLable.font];
    iframe.size.width = usernameautosize.width;
    iframe.origin.x = PHONE_SCREEN_SIZE.width-10-usernameautosize.width;
    _statisticsLable.frame = iframe;

    if(self.infoBgviewEnable == NO){
        //
        CGRect bottombarfram = self.frame;
        bottombarfram.size.height = PUBLISH_BOTTOM_HEIGHT;
        self.frame = bottombarfram;
        
        self.infoBgView.hidden = YES;//
//        CGRect theframe = self.frame;
//        theframe.size.height = theframe.size.height - PUBLISH_BOTTOM_INFO_HRIGHT;
//        self.frame = theframe;
        CGRect btnbgframe = self.buttonBgView.frame;
        btnbgframe.origin.y = 0;
        self.buttonBgView.frame = btnbgframe;
    }else {
        self.infoBgView.hidden = NO;//
        CGRect theframe = self.frame;
        theframe.size.height = PUBLISH_BOTTOM_HEIGHT + PUBLISH_BOTTOM_INFO_HRIGHT+1;
        self.frame = theframe;
        CGRect btnbgframe = self.buttonBgView.frame;
        btnbgframe.origin.y = PUBLISH_BOTTOM_INFO_HRIGHT+1;
        self.buttonBgView.frame = btnbgframe;
    }
    if(!(_checkBoxView.hidden =!self.checkBoxViewEnable)){
        CGRect checkviewfram = self.checkBoxView.frame;
        checkviewfram.size.width = current_X-2;
        self.checkBoxView.frame=checkviewfram;
        UIButton *checkboxbg = (UIButton *)[self.checkBoxView viewWithTag:10003];
        CGSize boximagesize = [[checkboxbg currentImage] size];
        CGRect backbuttonFrame = CGRectMake(5,
                                            (height - boximagesize.height)/2,
                                            boximagesize.width,
                                            boximagesize.height);
        checkboxbg.frame = CGRectIntegral(backbuttonFrame);
        UILabel *checkinfo = (UILabel *)[self.checkBoxView viewWithTag:10004];
        CGRect infofram = checkinfo.frame;
        infofram.origin.x = backbuttonFrame.origin.x+backbuttonFrame.size.width+2;
        infofram.size.width = checkviewfram.size.width - infofram.origin.x-2;
        checkinfo.frame = infofram;
    }
}

-(void)addLocationInfo:(NSMutableDictionary *)locationInfo{
    [self.locationInfo setDictionary:locationInfo];
    self.locationButton.selected = YES;
    _locationView.hidden = NO;
    //追加信息
    [self.locationInfo setObject:[locationInfo objectForKey:@"gps_longitude"] forKey:@"place_longitude"];
    [self.locationInfo setObject:[locationInfo objectForKey:@"gps_latitude"] forKey:@"place_latitude"];
    [self.locationInfo setObject:[NSNumber numberWithInt:1] forKey:@"locate_type"];
    [self.locationInfo setObject:[NSNumber numberWithInt:2] forKey:@"privacy"];
    [self.locationInfo setObject:[NSNumber numberWithInt:2] forKey:@"source_type"];
    
    [self layoutLocationWithName:[self.locationInfo objectForKey:@"place_name"]];
    
}
/*
 选中poi里面的一项，信息回调
 */
- (void)didSlectedPoiItem:(NSDictionary *)poiItemInfoDic{
    
    [self addLocationInfo:(NSMutableDictionary *)poiItemInfoDic];
    
}
-(NSMutableDictionary*)getLocationInfo{
    
    return self.locationInfo;
}
-(void)locationButtonClick:(id)senter{
    NSLog(@"syp====locationButtonClick");
    if (self.isLocationSucess) {
        //调用poi列表
        RNPoiListViewController *poilist = [[RNPoiListViewController alloc] init];
        if(self.parentViewController){
            [self.parentViewController presentModalViewController:poilist animated:YES];
        }
        poilist.delegate = self;
        [poilist release];
    }

}
-(BOOL)getCheckState{
    if (self.checkBoxView.isHidden == NO) {
        UIButton *checkbtn = (UIButton*)[self.checkBoxView viewWithTag:10003];
        return checkbtn.isSelected;
    }
    return NO;
}
-(void)setCheckState:(BOOL)state{
    if (self.checkBoxView.isHidden == NO) {
        UIButton *checkbtn = (UIButton*)[self.checkBoxView viewWithTag:10003];
        checkbtn.selected = state;
        _isWhisper = state;
    }
}
-(void)setCheckInfo:(NSString*)checkInfo{
    if (checkInfo == nil) {
        return;
    }
    if (self.checkBoxView.isHidden == NO) {
        UILabel *checkinfo = (UILabel*)[self.checkBoxView viewWithTag:10004];
        checkinfo.text = checkInfo;
    }
}
-(BOOL)btnChange:(PublisherBottomButtonType)btnType{

    switch (btnType) {
        case EPublishBottomAoduType://语音
            {
              if (self.expressionButtonFocus == YES) {
                    self.expressionButtonFocus = NO;
                    self.expressionButton.selected = NO;
              }
              if (self.audioButtonFocus == NO) {
                    self.audioButtonFocus = YES;
                    self.audioButton.selected = YES;
                    [self addAudioExtView];
                }else {
                    self.audioButtonFocus = NO;
                    self.audioButton.selected = NO;
                    [self cancleAudio];
                    [_bottomExtView removeFromSuperview];
                }
               
            }
            break;
        case EPublishBottomLocationType://定位
            {
                self.locationButton.selected = !self.locationButton.selected;
                _locationView.hidden = !self.locationButton.selected;
                // 当没有选中时，才去请求定位
                if(!_locationView.hidden){
                    if (!self.locationInfo || [self.locationInfo count]<=0) {
                        [self getLocationInfoFromCache];
                    }

                }else {
                    [self.locationInfo removeAllObjects];
                }
            }
            break;
        case EPublishBottomPhotoType://照片
            {
                UIActionSheet *sheet = nil; 
                sheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                    delegate:self  
                                           cancelButtonTitle:nil 
                                      destructiveButtonTitle:nil 
                                           otherButtonTitles:nil];
                [sheet addButtonWithTitle:NSLocalizedString(@"相册选择", @"相册选择")];
                [sheet addButtonWithTitle:NSLocalizedString(@"立刻拍照", @"立刻拍照")];    
                [sheet addButtonWithTitle:NSLocalizedString(@"取消", @"取消")]; 
                sheet.destructiveButtonIndex = 2;
                [sheet showFromRect:self.bounds inView:self animated:YES]; 
                [sheet release]; 
            }            
            break;
        case EPublishBottomAtType://点人
            {
                if (_isWhisper) {
                    [self showAlertWithMsg:NSLocalizedString(@"悄悄话里不能@好友哦！", @"悄悄话里不能@好友哦！")];
                }else if (self.canAtFriend == NO) {
                    [self showAlertWithMsg:NSLocalizedString(@"由于隐私设置不能@好友哦！", @"由于隐私设置不能@好友哦！")];
                }else {
                    RNAtFriendViewController *friendview = [[RNAtFriendViewController alloc] initWithOwnerId:self.uid];
                    friendview.atFrienddelete = self;
                    if(self.parentViewController){
                        [self.parentViewController presentModalViewController:friendview animated:YES];
                    }
                    [friendview release];
                }

            }          
            break;
        case EPublishBottomEmojeType://表情
            {
                if (self.audioButtonFocus == YES) {
                    self.audioButtonFocus = NO;
                    self.audioButton.selected = NO;
                    [self cancleAudio];
                }
                if (self.expressionButtonFocus == NO) {
                    self.expressionButtonFocus = YES;
                    self.expressionButton.selected = YES;
                    [self addexpressionExtView];
                }else {
                    self.expressionButtonFocus = NO;
                    self.expressionButton.selected = NO;
                    [_bottomExtView removeFromSuperview];
                }
            }  
            break;
            
        default:
            break;
    }

    return NO;
}
-(void)checkBoxClick:(UIButton*)btn{
    btn.selected = !btn.isSelected;
    _isWhisper = btn.isSelected;
}
-(void)buttonClick:(id)sender{
    UIButton* currentBtn = (UIButton*)sender;
    [self btnChange:currentBtn.tag];
    if (_btnDelegate) {
        if ([_btnDelegate respondsToSelector:@selector(publisherBottomButtonClick: bottonType:)] ) {
            [_btnDelegate publisherBottomButtonClick:currentBtn bottonType:currentBtn.tag ];
        }
    }
}
-(BOOL)setCurrentTextCount:(NSInteger)count{

    _currentCount=count;
    _statisticsLable.text = [NSString stringWithFormat:@"%d/%d",_currentCount,_maxCount];
    CGRect iframe = _statisticsLable.frame;
    CGSize usernameautosize = [_statisticsLable.text sizeWithFont:_statisticsLable.font];
    iframe.size.width = usernameautosize.width;
    iframe.origin.x = PHONE_SCREEN_SIZE.width-10-usernameautosize.width;
    _statisticsLable.frame = iframe;
    if (count > _maxCount) {
        
        [_statisticsLable setTextColor:[UIColor redColor]];
    }else {
        [_statisticsLable setTextColor:[UIColor blackColor]];
    }
    return  YES;
}
-(void)setMaxCount:(NSInteger)maxcount{
    _maxCount = maxcount;
    _statisticsLable.text = [NSString stringWithFormat:@"%d/%d",_currentCount,_maxCount];
    CGRect iframe = _statisticsLable.frame;
    CGSize usernameautosize = [_statisticsLable.text sizeWithFont:_statisticsLable.font];
    iframe.size.width = usernameautosize.width;
    iframe.origin.x = PHONE_SCREEN_SIZE.width-10-usernameautosize.width;
    _statisticsLable.frame = iframe;
}
-(void)initAudio{
    NSString *initParam = [[NSString alloc] initWithFormat:
						   @"server_url=%@,appid=%@",ENGINE_URL,APPID];
	// 识别控件
	_iFlyRecognizeControl = [[IFlyRecognizeControl alloc] initWithOrigin:H_CONTROL_ORIGIN theInitParam:initParam];
    //设置是否显示UI交互界面
    [_iFlyRecognizeControl setShowUI:FALSE];
	[self addSubview:_iFlyRecognizeControl];
	[_iFlyRecognizeControl setEngine:@"sms" theEngineParam:nil theGrammarID:nil];
	[_iFlyRecognizeControl setSampleRate:16000];
	_iFlyRecognizeControl.delegate = self;
	[initParam release];	
        
}
-(void)addexpressionExtView{
    [_bottomExtView removeFromSuperview];
    [_bottomExtView removeAllSubviews];
    CGRect extfram = _bottomExtView.frame;
    extfram.origin.y = self.superview.frame.size.height - PUBLISH_ENGISH_KEYBOARD_TOP;
    _bottomExtView.frame = extfram;
    RNEmotionView *_emotionview = [RNEmotionView getInstance];
    _emotionview.parentController =self;
    [_bottomExtView addSubview:_emotionview];
    [self.superview addSubview:_bottomExtView];
}
-(void)addEmotionInText:(NSString*)emojeText
{
    if (_btnDelegate) {
        if ([_btnDelegate respondsToSelector:@selector(onUpdateText: isAudio:)] ) {
            [_btnDelegate onUpdateText:emojeText isAudio:NO ];
        }
    }
}
-(void)addAudioExtView{
    //[_bottomExtView removeFromSuperview];
    [_bottomExtView removeFromSuperview];
    [_bottomExtView removeAllSubviews];
    CGRect extfram = _bottomExtView.frame;
    extfram.origin.y = self.superview.frame.size.height - PUBLISH_ENGISH_KEYBOARD_TOP;
    _bottomExtView.frame = extfram;//
    CGRect audiobgframe = CGRectMake(0, 0, extfram.size.width, extfram.size.height);
    //高亮部分
    UIView *height_bg = [[UIView alloc] initWithFrame:audiobgframe];
    [height_bg setBackgroundColor:[UIColor colorWithPatternImage:[[RCResManager getInstance] imageForKey:@"publisher_audio_state_bg_sl"]]];
    [_bottomExtView addSubview:height_bg];
    [height_bg release];
    
    UIView *nomal_bg = [[UIView alloc] initWithFrame:audiobgframe];
    nomal_bg.tag = 10005;
    [nomal_bg setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]];
    //[UIColor colorWithPatternImage:[[RCResManager getInstance] imageForKey:@"publisher_audio_state_bg"]]
    [_bottomExtView addSubview:nomal_bg];
    [nomal_bg release];

    
                        
    UIImageView *_micPic = [[UIImageView alloc] initWithImage:[[RCResManager getInstance] imageForKey:@"publisher_audio_bg"]];
    _micPic.frame = audiobgframe;
    [_bottomExtView addSubview:_micPic];
    [_micPic release];
    
    
    UIImage *btn_bg = [[RCResManager getInstance] imageForKey:@"button_bg"];
    UIImage *btn_bg_sl = [[RCResManager getInstance] imageForKey:@"button_bg_sl"];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setTitle:NSLocalizedString(@"取消", @"取消") forState:UIControlStateNormal];
    [cancleBtn setTitleColor:RGBCOLOR(40, 135, 214) forState:UIControlStateNormal];
    
    cancleBtn.frame = CGRectMake(27, audiobgframe.size.height-52, 114, 41);
    [cancleBtn addTarget:self action:@selector(cancleBtnClick:) forControlEvents:UIControlEventTouchDown];
    [cancleBtn setBackgroundImage:[btn_bg stretchableImageWithLeftCapWidth:btn_bg.size.width/2 topCapHeight:btn_bg.size.height/2] 
                       forState:UIControlStateNormal];
    [_bottomExtView addSubview:cancleBtn];
    
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneBtn setTitle:NSLocalizedString(@"开始", @"开始") forState:UIControlStateNormal];
    [doneBtn setTitle:NSLocalizedString(@"完成", @"完成") forState:UIControlStateSelected];
    doneBtn.tag = 10007;
    doneBtn.frame = CGRectMake(160, audiobgframe.size.height-52, 114, 41);
    [doneBtn addTarget:self action:@selector(doneBtnClick:) forControlEvents:UIControlEventTouchDown];
    [doneBtn setBackgroundImage:[btn_bg_sl stretchableImageWithLeftCapWidth:btn_bg_sl.size.width/2 topCapHeight:btn_bg_sl.size.height/2] 
                       forState:UIControlStateNormal];
    [_bottomExtView addSubview:doneBtn];
    
    [self.superview addSubview:_bottomExtView];
}
-(void)cancleBtnClick:(UIButton*)btn{
    [self cancleAudio];
    UIButton *donebtn = (UIButton *)[_bottomExtView viewWithTag:10007];
    donebtn.selected = NO;
}
-(void)doneBtnClick:(UIButton*)btn{
    btn.selected = !btn.isSelected;
    if (btn.isSelected) {
        if ([self startAudio]) {
            self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 
                                                               target:self 
                                                             selector:@selector(audioVisualizer:) 
                                                             userInfo:nil repeats:YES];
        }
    }else {
        [self stopAudio];
        [self changeSpeakPower:0];
    }
}
-(void)changeSpeakPower:(float)power{
    [UIView beginAnimations:@"" context:nil];
    UIView *normal_bg = [_bottomExtView viewWithTag:10005];
    CGRect normalframe = normal_bg.frame;
    float height = (PUBLISH_ENGISH_KEYBOARD_TOP-60)*(1-power);
    normalframe.size.height = height;
    normal_bg.frame = normalframe;
    [UIView commitAnimations];
}

-(void)audioVisualizer:(NSTimer *)timer{
    if(isAudioStart){
        float power = [_iFlyRecognizeControl getPower];
        NSLog(@"syp====audioVisualizer=%f",power );
        [self changeSpeakPower:power];
    }
    
    
//    [UIView setAnimationDuration:0.1f];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(growDidStop)];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [self resizeTextView:newSizeH];
//    
    
}

-(BOOL)startAudio{
    if (_iFlyRecognizeControl==nil) {
        [self initAudio];
    }
    isAudioStart=YES;
    return [_iFlyRecognizeControl start];
}
-(void)cancleAudio{
    isAudioStart = NO;
    [self.audioTimer invalidate];//timer停止则不再产生事件
    self.audioTimer = nil;//将timer设置成nil
    [_iFlyRecognizeControl cancel];
    //恢复音量初始位置
    [self changeSpeakPower:0];
    
}
//停止语音输入开始转换文字
-(void)stopAudio{
    isAudioStart = NO;
    [self.audioTimer invalidate];//timer停止则不再产生事件
    //self.audioTimer = nil;//将timer设置成nil
    [_iFlyRecognizeControl stop];
    //恢复音量初始位置
    [self changeSpeakPower:0];
}

//	识别结束回调
- (void)onRecognizeEnd:(IFlyRecognizeControl *)iFlyRecognizeControl theError:(SpeechError) error
{
    isAudioStart = NO;
    [self.audioTimer invalidate];//timer停止则不再产生事件
    self.audioTimer = nil;//将timer设置成nil
    //恢复音量初始位置
    [self changeSpeakPower:0];
    UIButton *donebtn = (UIButton *)[_bottomExtView viewWithTag:10007];
    donebtn.selected = NO;
	NSLog(@"识别结束回调finish.....");

	NSLog(@"getUpflow:%d,getDownflow:%d",[iFlyRecognizeControl getUpflow],[iFlyRecognizeControl getDownflow]);
	
}

- (void)onUpdateTextView:(NSString *)sentence
{
	NSLog(@"str===%@",sentence);
    if (_btnDelegate) {
        if ([_btnDelegate respondsToSelector:@selector(onUpdateText: isAudio:)] ) {
            [_btnDelegate onUpdateText:sentence isAudio:YES ];
        }
    }
}
- (void)onRecognizeResult:(NSArray *)array
{
	[self performSelectorOnMainThread:@selector(onUpdateTextView:) withObject:
	 [[array objectAtIndex:0] objectForKey:@"NAME"] waitUntilDone:YES];
}

- (void)onResult:(IFlyRecognizeControl *)iFlyRecognizeControl theResult:(NSArray *)resultArray
{
	[self onRecognizeResult:resultArray];	
}

//照片流程
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        //从相册选择//不能立即释放，内部逻辑需要
        if (_iphotocon == nil) {
            _iphotocon = [[RNPickPhotoHelper alloc] init];
        }
        _iphotocon.delegate = self;
        _iphotocon.parentViewContrller=self.parentViewController;
        
        [_iphotocon pickPhotoWithSoureType:UIImagePickerControllerSourceTypePhotoLibrary];
    }else if (buttonIndex == 1){
        //从相机拍照//不能立即释放，内部逻辑需要
        if (_iphotocon == nil) {
            _iphotocon = [[RNPickPhotoHelper alloc] init];
        }
        _iphotocon.parentViewContrller=self.parentViewController;
        _iphotocon.delegate = self;
        [_iphotocon pickPhotoWithSoureType:UIImagePickerControllerSourceTypeCamera];
    }else{
        //取消
    }
}

- (void)pickPhotoFinished:(UIImage *)imagePicked photoInfoDic: (NSDictionary * )photoInfoDic{
    
//    NSMutableDictionary *locationInfo= [NSMutableDictionary dictionaryWithCapacity:10];
//    [locationInfo setObject:cache.longitude forKey:@"gps_longitude"];
//    [locationInfo setObject:cache.latitude forKey:@"gps_latitude"];
//    [locationInfo setObject:[NSNumber numberWithInt:0] forKey:@"d"];
//    [locationInfo setObject:[NSNumber numberWithInt:4] forKey:@"locate_type"];
//    [locationInfo setObject:cache.poiName forKey:@"place_name"];
//    [locationInfo setObject:[NSNumber numberWithInt:2] forKey:@"privacy"];
//    [locationInfo setObject:[NSNumber numberWithInt:2] forKey:@"source_type"];
//    
 //   [self addLocationInfo:locationInfo];
    
    if (_btnDelegate) {
        if ([_btnDelegate respondsToSelector:@selector(onUpdatePhotoImage: photoInfoDic:)] ) {
            [_btnDelegate onUpdatePhotoImage:imagePicked photoInfoDic:photoInfoDic ];
        }
    }
}
//at好友回调
- (void)atFriendFinished:(NSDictionary * )friendInfoDic{
    NSMutableString *atdata = [NSMutableString stringWithString:@""];
    NSArray *keys = [friendInfoDic allKeys];
    for (NSNumber* key in keys) {
        [atdata appendString:[NSString stringWithFormat:@"@%@",[friendInfoDic objectForKey:key]]];
        [atdata appendString:[NSString stringWithFormat:@"(%@)",[key stringValue]]];
    }
    if (_btnDelegate) {
        if ([_btnDelegate respondsToSelector:@selector(onUpdateText: isAudio:)] ) {
            [_btnDelegate onUpdateText:atdata isAudio:NO ];
        }
    }
}
//清除所有状态
-(void)resetAllState{
    if (self.audioButtonFocus == YES) {
        self.audioButtonFocus = NO;
        self.audioButton.selected = NO;
        [self cancleAudio];
        [_bottomExtView removeFromSuperview];
    }
    if (self.expressionButtonFocus == YES) {
        self.expressionButtonFocus = NO;
        self.expressionButton.selected = NO;
        [_bottomExtView removeFromSuperview];
    }
}

// 从LBS缓存获取经纬度信息
- (void)getLocationInfoFromCache
{
    RCLBSCacheManager* manager = [RCLBSCacheManager sharedInstance];
    if(manager){
        manager.delegate = self;
        //[manager updateLocation:YES];
        [manager getLocCache];
    }
}

#pragma mark - RCLBSCacheManagerDelegate 
// 从LBS缓存获取经纬度信息成功
- (void)preLocateFinished:(RCLocationCache*)location
{
    NSMutableDictionary *locationInfo= [NSMutableDictionary dictionaryWithCapacity:10];
    
    self.isLocationSucess =YES;
    RCLBSCacheManager* manager = [RCLBSCacheManager sharedInstance];
    RCCurrentLocationPOICache* cache = manager.curLocPOICache;
    NSInteger distance = [manager distanceFromLatAndLng:cache.latitude srcLng:cache.longitude tagLat:location.latitude tagLng:location.longitude];
    if(abs(distance) < 500){
        //用poi缓存中的poiName作为默认POI
        [self layoutLocationWithName:cache.poiName];
       // [locationInfo setObject:cache.pid forKey:@"place_id"];
        [locationInfo setObject:cache.longitude forKey:@"gps_longitude"];
        [locationInfo setObject:cache.latitude forKey:@"gps_latitude"];
        [locationInfo setObject:[NSNumber numberWithInt:0] forKey:@"d"];
        [locationInfo setObject:[NSNumber numberWithInt:4] forKey:@"locate_type"];
        [locationInfo setObject:cache.poiName forKey:@"place_name"];
        [locationInfo setObject:[NSNumber numberWithInt:2] forKey:@"privacy"];
        [locationInfo setObject:[NSNumber numberWithInt:2] forKey:@"source_type"];
    }
    else {
        //用定位缓存中的门址作为默认POI
        [self layoutLocationWithName:location.gateSite];
        [locationInfo setObject:location.longitude forKey:@"gps_longitude"];
        [locationInfo setObject:location.latitude forKey:@"gps_latitude"];
        [locationInfo setObject:[NSNumber numberWithInt:0] forKey:@"d"];
        [locationInfo setObject:[NSNumber numberWithInt:1] forKey:@"locate_type"];
        [locationInfo setObject:location.gateSite forKey:@"place_name"];
        [locationInfo setObject:[NSNumber numberWithInt:2] forKey:@"privacy"];
        [locationInfo setObject:[NSNumber numberWithInt:2] forKey:@"source_type"];

    }    
    [self addLocationInfo:locationInfo];
}

// 从LBS缓存获取经纬度信息失败
- (void)preLocateFailed:(RCError*)error
{
    //需要确认，定位失败时的显示
    [self layoutLocationWithName:NSLocalizedString(@"定位失败", @"定位失败")];
}



@end
