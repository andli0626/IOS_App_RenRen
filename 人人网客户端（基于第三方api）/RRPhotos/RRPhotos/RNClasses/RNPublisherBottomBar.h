//
//  RNPublisherBottomBar.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-22.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iFlyISR/IFlyRecognizeControl.h"
#import "RNPickPhotoHelper.h"
#import "RNAtFriendViewController.h"
#import "RNView.h"
#import "RCLBSCacheManager.h"
#import "RNPoiListViewController.h"

typedef enum PublisherBottomButtonType{
    //语音
    EPublishBottomAoduType = 1000,
    //定位
    EPublishBottomLocationType,
    //照片
    EPublishBottomPhotoType,
    //点人
    EPublishBottomAtType,
    //表情
    EPublishBottomEmojeType
} PublisherBottomButtonType;
@protocol RNPublisherBottomBtnDelegate;


@interface RNPublisherBottomBar : RNView<IFlyRecognizeControlDelegate,RNPickPhotoDelegate,UIActionSheetDelegate
,RNAtFriendDelegate,RCLBSCacheManagerDelegate,RNPoiListDelegate>{

    //放置定位信息
    UIView *_locationView;
    //字数统计信息
    UILabel *_statisticsLable;
    //最大字数
    NSInteger _maxCount;
    NSInteger _currentCount;
    //背景
    UIImageView *_bagImage;
    //按钮区域的背景
    UIView *_buttonBgView;
    //统计信息区域的背景，和定位区域的背景
    UIView *_infoBgView;
    // 语音按钮
    UIButton *_audioButton;
    // 定位按钮
    UIButton *_locationButton;
    // 相册按钮
    UIButton *_photoButton;
    // 点人按钮
    UIButton *_atButton;
    // 表情按钮
    UIButton *_expressionButton;
    //checkbox
    UIView *_checkBoxView;
    //语音控件
    IFlyRecognizeControl *_iFlyRecognizeControl;
    NSTimer *_audioTimer;
    BOOL isAudioStart;//用于屏蔽科大讯飞的bug
    //底部扩展区功能
    UIView *_bottomExtView;
    //bottom底部按钮点击代理
    id<RNPublisherBottomBtnDelegate> _btnDelegate;

    //选择照片变量//因为其内部逻辑需求不能使用局部变量
    RNPickPhotoHelper *_iphotocon;
    NSMutableDictionary *_pictureInfo;
    //是否悄悄话或者隐私
    BOOL _isWhisper;
    //是否可@好友；
    BOOL _canAtFriend;
    //用户获取权限的uid
    NSNumber *_uid;
    //定位是否成功标记
    BOOL _isLocationSucess;
    NSMutableDictionary *_locationInfo;
    //用于导航的父controller
    UIViewController *_parentViewController;
    
    
}
//如过需要拍照和@好友功能的时候必须要传入父控件的controller否则将不能弹出子页面
@property (nonatomic, assign)   UIViewController *parentViewController;
//如果有权限则需要传入获取权限的ownerid
@property (nonatomic, retain)   NSNumber *uid;
@property (nonatomic, assign)   BOOL canAtFriend;

@property (nonatomic, readonly) UIButton *audioButton;
@property (nonatomic, readonly) UIButton *locationButton;
@property (nonatomic, readonly) UIButton *photoButton;
@property (nonatomic, readonly) UIButton *atButton;
@property (nonatomic, readonly) UIButton *expressionButton;
@property (nonatomic, readonly) UILabel  *statisticsLable;
@property (nonatomic, readonly) UIView   *buttonBgView;
@property (nonatomic, readonly) UIView   *infoBgView;
@property (nonatomic, readonly) UIView   *checkBoxView;
/*
 * 功能按钮是否可用，NO会隐藏按钮，默认为YES
 */
@property (nonatomic, assign) BOOL audioButtonEnable;
@property (nonatomic, assign) BOOL locationButtonEnable;
@property (nonatomic, assign) BOOL photoButtonEnable;
@property (nonatomic, assign) BOOL atButtonEnable;
@property (nonatomic, assign) BOOL expressionButtonEnable;
@property (nonatomic, assign) BOOL infoBgviewEnable;
//checkbox默认是no，隐藏。
@property (nonatomic, assign) BOOL checkBoxViewEnable;
//定位是否成功标记
@property (nonatomic, assign) BOOL isLocationSucess;
@property (nonatomic, retain)  NSMutableDictionary *locationInfo;
/*
 *是否展开功能区
 */
@property (nonatomic, assign) BOOL audioButtonFocus;
@property (nonatomic, assign) BOOL expressionButtonFocus;

//@property (nonatomic, assign) BOOL locationButtonFocus;
/*
 * 字数统计信息如果没有设置最大字数则默认240个字符
 */
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, assign) NSInteger currentCount;
//timer刷新音量频率
@property (nonatomic,retain) NSTimer *audioTimer;
/*
 * 按钮响应代理
 */
@property (nonatomic, assign) id<RNPublisherBottomBtnDelegate> btnDelegate;
/*
 *清除所有按键状态
 */
-(void)resetAllState;
/*
 *checkbox相关操作获取和设置checkbox的状态，如果check不显示则设置和获取均无效。
 */
-(BOOL)getCheckState;
-(void)setCheckState:(BOOL)state;
/*
 *设置checkbox的提示信息，如果check不显示则设置无效
 */
-(void)setCheckInfo:(NSString*)checkInfo;

/*
 *获得定位信息，如果当前正在定位或者没有开启定位则返回nil，否则将返回定位信息。
 */
-(NSMutableDictionary*)getLocationInfo;
//增加或者修改定位信息
-(void)addLocationInfo:(NSMutableDictionary *)locationInfo;

/*
 * 设置当前字数
 *@pram :count当前输入的字数
 *@return：是否能设置成功，如果当前字数大于最大字数限制则返回no设置失败，否则返回yes设置成功
 */
-(BOOL)setCurrentTextCount:(NSInteger)count;
/*
 * 开始语音输入
 */
-(BOOL)startAudio;
/*
 * 取消语音输入
 */
-(void)cancleAudio;
/*
 * 停止语音输入开始转换文字
 */
-(void)stopAudio;
/*
 *接收表情文字
 */
-(void)addEmotionInText:(NSString*)emojeText;
//按钮切换
-(BOOL)btnChange:(PublisherBottomButtonType)btnType;



@end
/*
 * 导航条代理
 */
@protocol RNPublisherBottomBtnDelegate <NSObject>
/*
 * 点击底边按钮
 * @pram:currentBotton当前点击按钮本身
 * @pram：bottonType 当前点击按钮的类型
 */
- (void)publisherBottomButtonClick:(UIButton*)currentBotton bottonType:(PublisherBottomButtonType)btnType;
/*
 * 通过语音转换的文本
 * @pram:audioText当前语音转换的文本
 * @pram:isaudio，true表示语音转换的文本，false表示表情获得的文本。
 */
-(void)onUpdateText:(NSString*)text isAudio:(BOOL)isaudio;

@optional
/*
 * 用于接受点击相册选取图片后返回的image数据
 * @pram:photoImage当前选取的image数据
 * @pram:photoInfoDic当前的照片信息（包括相册id，以及系统信息）
 */
-(void)onUpdatePhotoImage:(UIImage*)photoImage photoInfoDic: (NSDictionary * )photoInfoDic;
/*
 *定位成功后
 */
-(void)didLocation:(NSMutableDictionary*)locationinfo;
/*
 * 当前语音输入的状态
 */
//将要录音
-(void)onAudioShouldRecord;
//结束录音
-(void)onAudioStopRecord;
//将要从服务器获取文本
-(void)onAudioshouldGetText;
//获取到文本
-(void)onAudioFinishGetText;
//全部获取文本结束
-(void)onAudioAllFinish;
//取消语音识别
-(void)onAudioCancle;
@end





