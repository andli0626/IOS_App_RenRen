//
//  RNMiniPublisherView.m
//  RRSpring
//
//  Created by yi chen on 12-4-6.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNMiniPublisherView.h"
#import "RCMainUser.h"
#import "RCResManager.h"
#import "RNPublishRequestProto.h"

#define kTextFieldHight 48       //输入框的宽高
#define kTextFieldWidth 225      //有发送按钮或者回复数按钮时候文本框的宽度
#define KTextFieldWidthLarge 225  //横屏的宽度
#define kTextFieldPaddingLeft 19 //左填充
#define kTextFieldPaddingTop 8  //顶部填充
//(kTextFieldPaddingTop + kTextFieldHight)
#define kContainerViewHeight (self.frame.size.height) //此为RNMiniPublisherView的最佳高度
#define kContainerBgViewTag 1000

//发送按钮背景图,可点
#define kSendButtonBgImage (_isBlackStyle?@"bl_sendbutton":@"sendbutton") 
//发送按钮背景图片,不可点
#define kSendButtonDisableBgImage (_isBlackStyle? @"bl_sendbutton_disable":@"sendbutton_disable")  
//发送按钮高亮
#define kSendButtonBgHlImage (_isBlackStyle? @"bl_sendbutton_hl" : @"sendbutton_hl") 	
//评论数目背景图片
#define kSendButtonCommentBgImage (_isBlackStyle ? @"bl_comment_count":@"comment_count")	
//评论数目文字颜色
#define kSendButtonCommentTextColor (_isBlackStyle ? RGBCOLOR(188, 188, 188) : RGBCOLOR(81, 81, 81))
//盖在输入框上面的背景
#define kContainerViewBgImage (_isBlackStyle? @"bl_publisher_input":@"publisher_input")        
//文本内容的颜色
#define kGrowingViewTextColor (_isBlackStyle? [UIColor whiteColor] : [UIColor blackColor])
//键盘风格
#define kGrowinViewKeyboardAppearance (_isBlackStyle?UIKeyboardAppearanceAlert :UIKeyboardAppearanceDefault)
//默认提示文本的颜色
#define kPlaceHolderColor (RGBCOLOR(112, 112, 112))				

@interface  RNMiniPublisherView()

//当键盘出现的时候将输入框顶起来
- (void)keyboardShow:(NSNotification *)info;

//当键盘切换的时候做些必要的调整
- (void)keyboardHidden:(NSNotification *)info;

//点击发送按钮,发送网络请求
- (void)onClickSendButton;

- (void)setBottomBarBlackBg;

- (void)updateCommentCountLabel;

- (void)checkAtFriendPrivacy;

- (void)checkStyle;
@end


@implementation RNMiniPublisherView
@synthesize miniPublisherDelegate = _miniPublisherDelegate;
@synthesize containerView = _containerView;
@synthesize growingTextView = _growingTextView;
@synthesize sendButton = _sendButton;
@synthesize bottomBar = _bottomBar;
@synthesize commentType = _commentType;
@synthesize placeHolderLabel = _placeHolderLabel;
@synthesize commentCountLabel = _commentCountLabel;
@synthesize bIsShowCommentCount = _bIsShowCommentCount;
@synthesize commentNum = _commentNum;
@synthesize limitWordsLabel = _limitWordsLabel;
@synthesize parentControl = _parentControl;

/*----网络请求相关------*/
@synthesize publishPost	= _publishPost;
@synthesize query = _query;
@synthesize method = _method;
@synthesize requestAssistant = _requestAssistant;

#pragma  mark - 方法
-(void)dealloc{
	self.miniPublisherDelegate = nil;
	self.containerView = nil;
	self.growingTextView = nil;
	self.sendButton = nil;
	self.bottomBar = nil;
	self.commentCountLabel = nil;
	self.limitWordsLabel = nil;
	
	/*----网络请求相关------*/
	self.publishPost = nil;
	self.query = nil;
	self.method = nil;
	self.requestAssistant = nil;
	
	//消除键盘侦听
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

/*
 初始化
 @frame 位置区域
 @andCommentType 评论类型
 */
- (id)initWithFrame:(CGRect)frame andCommentType:(CommentType)commentType
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor blueColor]; //测试背景图片
		self.query = [NSMutableDictionary dictionary];
		//评论类型
		self.commentType = commentType;
		
		//记录最初的高度和Y
		oldY = frame.origin.y; 
		oldHeight = frame.size.height;
		
		//键盘通知中心
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];

		self.backgroundColor = [UIColor clearColor];//背景
		self.userInteractionEnabled = YES;
		
		[self addSubview:self.containerView];

		[self addSubview: self.bottomBar];
		//布局风格
		[self checkStyle];
    }
    return self;
}

/*
 初始化
 @frame 位置区域
 @andCommentType 评论类型
 @isBlackStyle 界面风格，默认为白色风格
 */
- (id)initWithFrame:(CGRect)frame 
	 andCommentType:(CommentType)commentType 
	   isBlackStyle: (BOOL)isBlackStyle{

	_isBlackStyle = isBlackStyle;
	if (self = [self initWithFrame:frame andCommentType:commentType]) {
		
	}
	return self;
}

- (RNPublisherBottomBar *)bottomBar{
	
	if (!_bottomBar) {
		//工具栏：表情，语音，@好友
		_bottomBar = [[RNPublisherBottomBar alloc]initWithFrame:CGRectMake(0, 
																		   kContainerViewHeight, 
																		   PHONE_SCREEN_SIZE.width, 
																		   PUBLISH_BOTTOM_HEIGHT )];
		_bottomBar.locationButtonEnable = NO;
		_bottomBar.photoButtonEnable = NO; //禁止拍照和定位功能
		_bottomBar.infoBgviewEnable = NO;
		_bottomBar.btnDelegate = self;
	}
	return _bottomBar;
}

- (HPGrowingTextView *)growingTextView{
	//动态伸缩输入框
	if (!_growingTextView) {
		_growingTextView = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(kTextFieldPaddingLeft, 
																			  kTextFieldPaddingTop, 
																			  kTextFieldWidth, 
																			  kTextFieldHight)];
		_growingTextView.backgroundColor = [UIColor clearColor];
//		_growingTextView.font = [UIFont fontWithName:MED_HEITI_FONT size:15];
		_growingTextView.font = [UIFont systemFontOfSize:15.0f];
		_growingTextView.maxNumberOfLines = 3;
		_growingTextView.minNumberOfLines = 1;
		//不支持错误纠正
		[_growingTextView.internalTextView setAutocorrectionType:UITextAutocorrectionTypeYes];
		_growingTextView.internalTextView.spellCheckingType  = UITextSpellCheckingTypeNo;
		_growingTextView.returnKeyType = UIReturnKeyDefault;
		_growingTextView.delegate = self;
		_growingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 1, 0);
		
		_growingTextView.backgroundColor = [UIColor clearColor];
		_growingTextView.internalTextView.backgroundColor = [UIColor clearColor];
		
		//默认文案
		UILabel *placeHolderLabel = [[UILabel alloc]initWithFrame:
									 CGRectMake(10, 0, _growingTextView.width, _growingTextView.height)];
		placeHolderLabel.backgroundColor = [UIColor clearColor];
		placeHolderLabel.text = NSLocalizedString(@"添加回复", @"添加回复");
		placeHolderLabel.hidden = NO;
		placeHolderLabel.font = _growingTextView.font;
		self.placeHolderLabel = placeHolderLabel;
		[_growingTextView addSubview:placeHolderLabel];
		TT_RELEASE_SAFELY(placeHolderLabel);
		
		//字数限制提醒标签
		UILabel *limitWordsLabel = [[UILabel alloc]init];//先不设置区域Frame,在字数超出是才设
		
		limitWordsLabel.font  = [UIFont fontWithName:MED_HEITI_FONT size:15];
		limitWordsLabel.backgroundColor = [UIColor clearColor];
		limitWordsLabel.textColor = [UIColor redColor];//提醒文字为红色
		limitWordsLabel.hidden = YES;//默认是隐藏
		
		[_growingTextView addSubview:limitWordsLabel];
		self.limitWordsLabel = limitWordsLabel;
		TT_RELEASE_SAFELY(limitWordsLabel);
	}

	return _growingTextView;	
}

- (UIView *)containerView{
	//输入框和发送按钮（评论数按钮）的容器
	if (!_containerView) {
		_containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width , kContainerViewHeight)];
		_containerView.backgroundColor = [UIColor clearColor];


		//添加输入框背景，盖在输入框上面
		UIImage *containerBgImage = [[RCResManager getInstance]imageForKey:kContainerViewBgImage];
		UIImageView *containerBgView = [[UIImageView alloc]initWithImage: //设置可以拉伸的范围
										[containerBgImage stretchableImageWithLeftCapWidth:containerBgImage.size.width / 2
																			  topCapHeight:containerBgImage.size.height / 2] ];
		containerBgView.backgroundColor = [UIColor clearColor];
		containerBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

		containerBgView.tag = kContainerBgViewTag;
		[_containerView addSubview:containerBgView];
		TT_RELEASE_SAFELY(containerBgView);
		
		[_containerView addSubview:self.sendButton];
		[_containerView addSubview: self.growingTextView];
	}
	return _containerView;
}

- (UIButton *)sendButton{
	//发送按钮，初始状态可能是评论数目
	if (!_sendButton) {
		_sendButton = [[UIButton alloc]init];
		[_sendButton setImage:[[RCResManager getInstance]imageForKey: kSendButtonCommentBgImage ]
					 forState:UIControlStateNormal];
		[_sendButton addTarget:self action:@selector(onClickSendButton) 
			  forControlEvents:UIControlEventTouchDown];
		CGSize buttonSize = [_sendButton currentImage].size;
		_sendButton.frame = CGRectMake( 256, 
									  9, 
									  buttonSize.width, 
									  buttonSize.height);
		
		[_sendButton addSubview:self.commentCountLabel];
		
		if (_commentType == ECommentShareType || _commentType == ECommentStatusType) {
			_LimitWordsNum = 240;
		}else {
			_LimitWordsNum = 140; // 最大评论字数为140
		}
		_bIsSendStatus = NO; //开始处于评论数状态
	}
	return _sendButton;
}

- (UILabel *)commentCountLabel{
	//添加评论数目
	if (!_commentCountLabel) {
		_commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(29, 12, 17, 11)];
		_commentCountLabel.backgroundColor = [UIColor clearColor];
		_commentCountLabel.font  = [UIFont fontWithName:MED_HEITI_FONT size:9];
		_commentCountLabel.text = [NSString stringWithFormat:@"%d",_commentNum]; //评论数
	}

	return _commentCountLabel;
}
#pragma -mark  设置网络请求参数

/*
	设置网络请求参数
	@query:请求参数对，共有的参数可以不传,每次参数变化的时候要先重置下query
	@method：请求的接口名字
 */
- (void)resetQuery:(NSMutableDictionary *)query {
	
	[self.query removeAllObjects];//清空所有的内容
	[self.query setValuesForKeysWithDictionary:query];
	
	[self updateCommentCountLabel];//更新评论数标签
	[self checkAtFriendPrivacy];
}

/*
	设置网络请求参数 每次参数变化的时候要先重置下query
	@query:请求参数对，共有的参数可以不传,具体详见wiki接口说明
	一般的评论只要传入 id：分享的id user_id：分享所有者的id ...
	@commentNum:外部传入的评论数目（将不会主动请求更新评论数目）
 */
- (void)resetQuery:(NSMutableDictionary *)query andCommentCount: (NSInteger)commentNum {
	[self.query removeAllObjects];//清空所有的内容
	[self.query setValuesForKeysWithDictionary:query];	
	
	_commentNum = commentNum;
	self.commentCountLabel.text = [NSString stringWithFormat:@"%d",_commentNum]; //评论数
}

/*
	发送网络请求去更新评论数目
 */
- (void)updateCommentCountLabel{
	
	////////////以下设置是为了获取内容的评论数/////////////
	self.requestAssistant = [RCGeneralRequestAssistant requestAssistant];

	self.requestAssistant.onCompletion = ^(NSDictionary* result){
		NSLog(@"cy---------------获取评论数成功：%@" ,result);
		if ([result objectForKey:@"count"]) { //获得评论数
			_commentNum = [[result objectForKey:@"count"]intValue];
			self.commentCountLabel.text = [NSString stringWithFormat:@"%d",_commentNum]; //评论数
		}
	};
	self.requestAssistant.onError = ^(RCError* error) {

		NSLog(@"cy---------------获取评论数失败：%@" ,error.titleForError);		
	};
	
	RCMainUser *mainUser = [RCMainUser getInstance];
	NSMutableDictionary *dics = [NSMutableDictionary dictionaryWithCapacity:10];
	NSString* methodName = nil;
	[dics setValue:mainUser.sessionKey forKey:@"session_key"];
	
	if (_commentType == ECommentBlogType || _commentType == ECommentShareType) {
		if ([self.query objectForKey:@"user_id"]) {
			[dics setValue:[self.query objectForKey:@"user_id"] forKey:@"user_id"];//分享所有者的id
			
		}
		if ([self.query objectForKey:@"id"]) {
			[dics setValue:[self.query objectForKey:@"id"] forKey:@"id"]; //分享的id
		}
		
		if (_commentType == ECommentBlogType) {
			methodName = @"blog/getComments"; //获得日志评论数
		}else {
			methodName = @"share/getComments";//获得分享评论数
		}
	}
	
	if (_commentType == ECommentStatusType) { //状态评论
		if ([self.query objectForKey:@"owner_id"]) {
			[dics setValue:[self.query objectForKey:@"owner_id"] forKey:@"owner_id"];//状态所有者id
			
		}
		if ([self.query objectForKey:@"status_id"]) {
			//此处关键字status_id 就是status/getComments 中的id，坑爹，两个接口的key还不一样。
			[dics setValue:[self.query objectForKey:@"status_id"] forKey:@"id"]; //状态id
		}
		methodName = @"status/getComments"; //获得状态评论数
	}
	
	if( _commentType == ECommentPhotoType){
		if ([self.query objectForKey:@"uid"]) {
			[dics setValue:[self.query objectForKey:@"uid"] forKey:@"uid"]; 
		}
		if ([self.query objectForKey:@"pid"]) {
			[dics setValue:[self.query objectForKey:@"pid"] forKey:@"pid"]; 
		}
		
		methodName = @"photos/getComments"; //获得照片的评论数
	}
	
	if(_commentType == ECommentAlbumType){
		if ([self.query objectForKey:@"aid"]) {
			[dics setValue:[self.query objectForKey:@"aid"] forKey:@"aid"]; //相册的id
		}
		if ([self.query objectForKey:@"uid"]) {
			[dics setValue:[self.query objectForKey:@"uid"] forKey:@"uid"]; //相册的所有者的用户id
		}
		
		methodName = @"photos/getComments"; //获得相册的评论数
	}
	
	if (_commentType == ECommentCheckinType) {
		if ([self.query objectForKey:@"cid"]) {
			[dics setValue:[self.query objectForKey:@"cid"] forKey:@"cid"]; 
		}
		if ([self.query objectForKey:@"uid"]) {
			[dics setValue:[self.query objectForKey:@"uid"] forKey:@"uid"]; 
		}
		methodName = @"place/getCheckinComments";
	}
	if (_commentType == ECommentEvaluationType) {
		if ([self.query objectForKey:@"id"]) {
			[dics setValue:[self.query objectForKey:@"id"] forKey:@"id"]; 
		}
		if ([self.query objectForKey:@"owner_id"]) {
			//又有个参数名字不一致！
			[dics setValue:[self.query objectForKey:@"owner_id"] forKey:@"user_id"]; 
		}
		methodName = @"place/getEvaluationComments";
	}
	
	//modify 此处只有blog 和 相片内容页面更新评论数
	if(_commentType == ECommentBlogType || _commentType == ECommentPhotoType){
		[self.requestAssistant sendQuery:dics withMethod:methodName];//发送获取评论数请求
	}
	
}

/* 
	------获取@好友权限------- 
 */
- (void)checkAtFriendPrivacy {
	
	self.requestAssistant = [RCGeneralRequestAssistant requestAssistant];
	self.requestAssistant.onCompletion = ^(NSDictionary* result){
		NSLog(@"cy---------------检查@好友权限成功：%@" ,result);
		NSNumber *level = [result objectForKey:@"privacy_level"];
        if (level) {
            if ( 1 == [level intValue]) { //仅好友可见
				if ([self.query objectForKey:@"uid"]) {
					self.bottomBar.uid = [self.query objectForKey:@"uid"];
				}
				if ([self.query objectForKey:@"owner_id"]) {
					self.bottomBar.uid = [self.query objectForKey:@"owner_id"];
				}
            }else if(2 == [level intValue]){ //仅自己可见
                self.bottomBar.canAtFriend = NO;
            }
        } 
	};
	self.requestAssistant.onError = ^(RCError* error) {
		NSLog(@"cy---------------检查@好友权限失败：%@" ,error.titleForError);		
	};

	RCMainUser *mainUser = [RCMainUser getInstance];
	NSMutableDictionary *dics1 = [NSMutableDictionary dictionaryWithCapacity:10];
	NSString* methodName1 = nil;
	[dics1 setValue:mainUser.sessionKey forKey:@"session_key"];
	
	
	if ( _commentType == ECommentBlogType) {
		if ([self.query objectForKey:@"id"]) {
			[dics1 setValue:[self.query objectForKey:@"id"] forKey:@"id"];
		}
		if ([self.query objectForKey:@"user_id"]) {
			[dics1 setValue:[self.query objectForKey:@"user_id"] forKey:@"owner_id"];	
		}
		methodName1 = @"blog/privacy";
	}
	if (_commentType == ECommentPhotoType || _commentType == ECommentAlbumType) {
		if ([self.query objectForKey:@"uid"]) {
			[dics1 setValue:[self.query objectForKey:@"uid"] forKey:@"owner_id"];
		}
		if (_commentType == ECommentAlbumType) {
			if ([self.query objectForKey:@"aid"]) {
				[dics1 setValue:[self.query objectForKey:@"aid"] forKey:@"id"]; //相册的id
			}
		}else{
			if ([self.query objectForKey:@"pid"]) {
				[dics1 setValue:[self.query objectForKey:@"pid"] forKey:@"id"]; //相册的id
			}
		}
		methodName1 = @"photos/privacy";
	}
	
	[self.requestAssistant sendQuery:dics1 withMethod:methodName1];
}

/*
	重置评论
 */
- (void)setCommentType:(CommentType)commentType{
	
	_commentType = commentType;
	
	switch (self.commentType) {
		case ECommentBlogType:
		{
			self.method = @"blog/addComment"; //添加日志评论接口
			self.bottomBar.checkBoxViewEnable = YES;
		}break;
			
		case ECommentShareType:
		{
			self.method = @"share/addComment";
		}break;
			
		case ECommentStatusType:
		{
			self.method = @"status/addComment"; //添加状态评论接口
		}break;
			
		case ECommentAlbumType:
		case ECommentPhotoType:
		{
			self.method = @"photos/addComment"; //添加照片评论
			self.bottomBar.checkBoxViewEnable = YES;
		}break;
		
		case ECommentCheckinType:
		{
			self.method = @"place/addCheckinComment";
		}break;
		case ECommentEvaluationType:
		{
			self.method = @"place/addEvaluationComment";
		}break;
		default:
			break;
	}
}

/*
	设置界面风格
 */
- (void)checkStyle{
	//设置输入框的背景
	UIImage *containerBgImage = [[RCResManager getInstance]imageForKey:kContainerViewBgImage];

	[((UIImageView *)[self.containerView viewWithTag:kContainerBgViewTag ]) 
	 setImage: [containerBgImage stretchableImageWithLeftCapWidth:containerBgImage.size.width / 2
																		topCapHeight:containerBgImage.size.height / 2]];

	//设置输入框的风格背景
	if (_isBlackStyle) { 
		//重置黑色风格
		[self setBottomBarBlackBg];
	}
	
	self.growingTextView.internalTextView.keyboardAppearance = kGrowinViewKeyboardAppearance; 
	self.growingTextView.internalTextView.indicatorStyle  = 
	_isBlackStyle?UIScrollViewIndicatorStyleWhite:UIScrollViewIndicatorStyleBlack;
	self.growingTextView.textColor = kGrowingViewTextColor;

	//默认文案的字颜色
	self.placeHolderLabel.textColor = kPlaceHolderColor;

	
	self.commentCountLabel.textColor = kSendButtonCommentTextColor;
	if (_isBlackStyle) { // 黑色风格的时候有阴影
		self.commentCountLabel.shadowColor = RGBACOLOR(0, 0, 0, 0.3);
		self.commentCountLabel.shadowOffset = CGSizeMake(0, -2);
	}else {
		self.commentCountLabel.shadowColor = [UIColor clearColor];
	}

}

- (void)layoutSubviews{
	if (_bIsSendStatus) {
		_containerView.width = 320;
	}else if(!_bIsShowCommentCount ){ //是否显示评论数目
		_containerView.width = 380;
	}else if(_bIsShowCommentCount) { //如果在底部，且要显示评论数
		_containerView.width = 320;
	}

	//设置按钮的位置
	self.sendButton.frame = CGRectMake( self.containerView.size.width - 5 - self.sendButton.currentImage.size.width, 
									   self.containerView.size.height - 6 -  self.sendButton.currentImage.size.height, 
									   self.sendButton.currentImage.size.width,
									   self.sendButton.currentImage.size.height);

	self.bottomBar.top = self.containerView.bottom ;
	for (UIView *subView in [self subviews]) {
		if (subView != self.containerView && subView != self.bottomBar) {
			subView.top = self.bottomBar.bottom;
		}
	}
	
}

/*
	设置工具栏成黑色背景
 */
- (void)setBottomBarBlackBg{
	[self.bottomBar.audioButton setImage:[[RCResManager getInstance]imageForKey:@"bl_audio"] forState:UIControlStateNormal];
	[self.bottomBar.audioButton setImage:[[RCResManager getInstance]imageForKey:@"bl_audio_hl"] forState:UIControlStateHighlighted];
	[self.bottomBar.audioButton setImage:[[RCResManager getInstance]imageForKey:@"bl_audio_hl"] forState:UIControlStateSelected];				
	
	[self.bottomBar.atButton setImage:[[RCResManager getInstance]imageForKey:@"bl_@"] forState:UIControlStateNormal];
	[self.bottomBar.atButton setImage:[[RCResManager getInstance]imageForKey:@"bl_@_hl"] forState:UIControlStateHighlighted];
	
	
	[self.bottomBar.expressionButton setImage:[[RCResManager getInstance]imageForKey:@"bl_emotion"] forState:UIControlStateNormal];
	[self.bottomBar.expressionButton setImage:[[RCResManager getInstance]imageForKey:@"bl_emotion_hl"] forState:UIControlStateHighlighted];
	[self.bottomBar.expressionButton setImage:[[RCResManager getInstance]imageForKey:@"bl_emotion_hl"] forState:UIControlStateSelected];
	[self.bottomBar.buttonBgView setBackgroundColor:RGBCOLOR(172, 172, 172)];
}

/*
	重写ParentControl,方便@好友界面正常弹出
 */

- (void)setParentControl:(UIViewController *)parentControl{
	_parentControl = parentControl;
	//将parentViewController传给bottomBar
	self.bottomBar.parentViewController = _parentControl;
}

/* 
	当键盘出现的时候将输入框顶起来
 */
- (void)keyboardShow:(NSNotification *)info{
	
	_bIsSendStatus = YES;//处于发送状态

    NSDictionary *keyboardInfo = [info userInfo];
    NSValue *rectValue = [keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect = [rectValue CGRectValue];
	
	NSDictionary *userInfo = [info userInfo];
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];

	//有发送按钮时候输入框变窄
	self.growingTextView.width = kTextFieldWidth; 
	//出现发送按钮
	self.sendButton.hidden = NO;
	//移除评论数目的标签
	[self.commentCountLabel removeFromSuperview];
	
	//将原始的按钮背景设为发送背景图
	[self.sendButton setImage:[[RCResManager getInstance]imageForKey: kSendButtonBgImage ]forState:UIControlStateNormal];
	[self.sendButton setImage:[[RCResManager getInstance]imageForKey:kSendButtonBgHlImage ]forState:UIControlEventTouchUpInside];
//	[self.sendButton setImage:[[RCResManager getInstance]imageForKey:kSendButtonDisableBgImage] forState:UIControlStateDisabled];
	
	[UIView animateWithDuration:animationDuration animations:^(){
		self.frame = CGRectMake(self.frame.origin.x, 
								oldY  - PUBLISH_BOTTOM_HEIGHT - keyboardRect.size.height ,
								self.frame.size.width, 
								oldHeight + PUBLISH_BOTTOM_HEIGHT + keyboardRect.size.height);
	} ];
	//取消所有工具栏的选中，玉平提供
	[self.bottomBar resetAllState];

	[self layoutIfNeeded];
}

//当键盘消失的时候
- (void)keyboardHidden:(NSNotification *)info{

	if (_bBottomBarFocus) {
		NSDictionary *userInfo = [info userInfo];
		NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
		NSTimeInterval animationDuration;
		[animationDurationValue getValue:&animationDuration];
	
		[UIView animateWithDuration:animationDuration animations:^(){
			self.frame = CGRectMake(self.frame.origin.x, 
									oldY - PUBLISH_ENGISH_KEYBOARD_TOP - PUBLISH_BOTTOM_HEIGHT ,
									self.frame.size.width, 
									_containerView.height + PUBLISH_ENGISH_KEYBOARD_TOP + PUBLISH_BOTTOM_HEIGHT  );
			
		}];
		
		_bBottomBarFocus = NO;
	}
}

//将整个输入界面下拉到原来的位置（底部）,一般由superview去调用
- (void)pullViewDown{
	if (!_bIsSendStatus){
		return; //如果已经在底部了。就直接返回。
	}
	
	_bIsSendStatus = NO; //处于评论状态
	NSLog(@"cy------界面下拉 pullViewDown");
	[self.growingTextView resignFirstResponder];//取消第一响应
	
	[UIView animateWithDuration:0.3 animations:^(){
		
		self.frame = CGRectMake(self.frame.origin.x, oldY,self.frame.size.width, oldHeight);
		[self.sendButton setImage:[[RCResManager getInstance]imageForKey: kSendButtonCommentBgImage ]forState:UIControlStateNormal];
		self.sendButton.hidden = NO;
		[self.sendButton addSubview:self.commentCountLabel];
		
		self.growingTextView.width = KTextFieldWidthLarge;
	}completion:^(BOOL finished){
		if (self.miniPublisherDelegate) { //动画结束事件回调
			if ([self.miniPublisherDelegate respondsToSelector:@selector(pullDownFinished)]) {
				[self.miniPublisherDelegate pullDownFinished];
			}
		}
		self.sendButton.enabled = YES; //按钮处于评论数状态可以点击
	}];
	
	[self layoutIfNeeded];
}

//将整个界面上拉，包括输入框，中间栏，键盘
- (void)pullViewUp{
	[self.growingTextView becomeFirstResponder];
	NSLog(@"cy-------pullViewUp 界面上拉");
}

/*
 往文本框里面追加文字内容
 */
- (void)inputGrowingText:(NSString*) text{
	self.growingTextView.text = [NSString stringWithFormat:@"%@%@",self.growingTextView.text,text];
}

/*
 设置文本框内容
 */
- (void)setGrowingText:(NSString*) text{
	self.growingTextView.text = text;
}

#pragma -mark 点击发送按钮,发送网络请求
- (void)onClickSendButton{

	/* ------按钮处于评论数目状态------ */
	if ( !_bIsSendStatus ) { 
		if (self.miniPublisherDelegate ) { //回调评论数目按钮被点击了
			if ([self.miniPublisherDelegate respondsToSelector:@selector(onClickCommentCountButton)]) {
				[self.miniPublisherDelegate onClickCommentCountButton];
			}
		}
		return;
	}
	
	/* -----按钮处于发送状态----- */
	if (self.query && self.method) { //发出评论请求
		self.publishPost = nil;  //先释放掉原来的
		_publishPost = [[RCPublishPost alloc]init]; //重新申请发送，以免多次点击发送，会失败
		
		RCMainUser *mainUser = [RCMainUser getInstance];
		if (![self.query objectForKey:@"session_key"]) {
			[self.query setValue:mainUser.sessionKey forKey:@"session_key"]; //session_key
		}
		[self.query setValue:self.growingTextView.text forKey:@"content"]; //设置评论的内容
		
		if (self.bottomBar.checkBoxViewEnable == YES) { //如果有悄悄话功能
			switch (_commentType) {
				case ECommentBlogType:
				{
					if ([self.bottomBar getCheckState]) { //是悄悄话
						[self.query setObject:[NSNumber numberWithInt:1] forKey:@"type"];
					}
				}break;
				case ECommentAlbumType:
				case ECommentPhotoType:
				{
					if ([self.bottomBar getCheckState]) { //是悄悄话
						[self.query setObject:[NSNumber numberWithInt:1] forKey:@"whisper"];
					}
				}break;
				default:
					break;
			}
		}
		[self.publishPost publishPostWith:nil paramDic:self.query withMethod:self.method];
	}
	[self pullViewDown];//下拉输入框
	[self updateCommentCountLabel];//更新评论数

	//回调传回数据
	if (self.miniPublisherDelegate) {
		if ([self.miniPublisherDelegate respondsToSelector:@selector(publishRequestData:)]) {
			NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
			[resultDic setObject:self.growingTextView.text forKey:@"content"];
            [resultDic setObject:[self.publishPost.pair objectForKey:@"call_id"] forKey:@"call_id"];
			[self.miniPublisherDelegate publishRequestData:resultDic];
		}
	}
	self.growingTextView.text = @"";
}

#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
	float diff = (growingTextView.frame.size.height - height);
	if (abs(diff) < 10) { //去抖动
		return;
	}
	
	[UIView animateWithDuration:0.5 animations:^(){
		float diff = (growingTextView.frame.size.height - height);
		if (diff  < -10 ) { //如果输入框高度是增加的
			//伸缩框高度下移
			growingTextView.origin = CGPointMake(growingTextView.origin.x, growingTextView.origin.y + 3);
			diff -= 6;
		}else if(diff > 10) {
			//伸缩框高度上移
			growingTextView.origin = CGPointMake(growingTextView.origin.x, growingTextView.origin.y - 3);
			diff += 6;
		}
		
		CGRect r = self.containerView.frame;
		r.size.height -= diff;
		self.containerView.frame = r; 
		
		oldY += diff;
		oldHeight -= diff;
		
		r = self.frame;
		r.size.height -= diff;
		r.origin.y += diff;
		self.frame = r;
		
	}];
   	//此处重新布局下，否则会有闪的感觉
	[self layoutIfNeeded];
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView{
	
	if (self.growingTextView.text.length > 0) { //整理下，不是空格，换行
        NSString* temp = [growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([temp length] == 0){
            self.sendButton.enabled = NO;
        }else{
            self.sendButton.enabled = YES;
        }
    }else {
        self.sendButton.enabled = NO;
    }
	
	//通知外部输入框被点击了
	if (self.miniPublisherDelegate){
		if ([self.miniPublisherDelegate respondsToSelector:@selector(textViewShouldBeginEditing)]) {
			[self.miniPublisherDelegate textViewShouldBeginEditing];
		}
	}
	return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    if (self.growingTextView.text.length > 0) { //整理下，不是空格，换行
        NSString* temp = [growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([temp length] == 0){
            self.sendButton.enabled = NO;
        }else{
            self.sendButton.enabled = YES;
        }
    }else if(_bIsSendStatus){
        self.sendButton.enabled = NO;
    }
	
	//判断字符限制
	if (self.growingTextView.text.length > _LimitWordsNum) { 
		self.limitWordsLabel.frame = CGRectMake(self.growingTextView.width - 40, self.growingTextView.height - 15, 40, 15);
		self.limitWordsLabel.text = [NSString stringWithFormat:
									 @"-%d",self.growingTextView.text.length - _LimitWordsNum];
		self.limitWordsLabel.hidden = NO;
		
    }else{
		self.limitWordsLabel.hidden = YES;
    }
	
	if ( 0 == self.growingTextView.text.length ) { //如果为空则显示默认文案
		self.placeHolderLabel.hidden = NO;
		[self.growingTextView layoutIfNeeded];
	}
	else {
		self.placeHolderLabel.hidden = YES;
		[self.growingTextView layoutIfNeeded];
	}
}

-(void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView{
   
}

#pragma -mark RNPublisherBottomBtnDelegate
/*
	点击底边按钮
	@pram:currentBotton当前点击按钮本身
	@pram：bottonType 当前点击按钮的类型
 */
- (void)publisherBottomButtonClick:(UIButton*)currentBotton bottonType:(PublisherBottomButtonType)btnType{
	_bBottomBarFocus = YES;

	if (_bottomBar.audioButtonFocus || _bottomBar.expressionButtonFocus) {

		[self.growingTextView resignFirstResponder];
    }else if(_bottomBar.audioButtonFocus == NO || _bottomBar.expressionButtonFocus == NO){
        [self.growingTextView becomeFirstResponder];
    }
}

/*
	通过语音转换的文本
	@pram:audioText当前语音转换的文本
	@pram:isaudio，true表示语音转换的文本，false表示表情获得的文本。
 */
-(void)onUpdateText:(NSString*)text isAudio:(BOOL)isaudio{
	self.growingTextView.text = [NSString stringWithFormat:@"%@%@",self.growingTextView.text,text];
}
@end
