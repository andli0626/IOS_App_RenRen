//
//  RNMiniPublisherView.h
//  RRSpring
//
//  Created by yi chen on 12-4-6.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h" //动态伸缩输入框
#import "RNPublisherBottomBar.h"
#import "RCGeneralRequestAssistant.h"
#import "RCBaseRequest.h"
#import "RCPublishPost.h"
//#import "RCPhotosUpload.h"
#import "RNView.h"

#define kMiniPublisherHeight 48

@protocol RNPublishRequestProto;

/*
 *	评论的类型，用于区分button的初始状态和最大回复字数
 */
typedef enum {
	ECommentAlbumType = 0,//相册评论页
	ECommentPhotoType = 1,//照片评论
	ECommentBlogType = 2,//日志内容页评论
	//以上三种的评论，按钮的初始状态为回复数，弹起后为发送按钮，回复的最大字数为140
	
	ECommentShareType = 3,//分享评论
	ECommentStatusType = 4,//状态评论
	//初始状态为发送按钮，回复的最大字数为240
	
	ECommentCheckinType = 5, //报道 -----暂时没有处理
	ECommentEvaluationType = 6, //地点评价 -----暂时没有处理
}CommentType;

/*
	mini代理
 */
@protocol RNMiniPublisherDelegate <RNPublishRequestProto>

@optional
/*
	下拉动画事件完成回调
 */
- (void)pullDownFinished;

/*
	用于通知输入框被点击了
 */
- (void)textViewShouldBeginEditing;

/*
	评论数按钮被点击了
 */
- (void)onClickCommentCountButton;

@end


/*
 * 小Publisher UI 
 * 创建位置最佳设为：  CGRectMake(0, PHONE_SCREEN_SIZE.height - 48, PHONE_SCREEN_SIZE.width, 48) 
 * 如果初始不需要呈现，那么可以先设隐藏
 */
@interface RNMiniPublisherView : RNView <RNPublisherBottomBtnDelegate ,HPGrowingTextViewDelegate>
{
	//mini代理
	id<RNMiniPublisherDelegate> _miniPublisherDelegate;
	
	//输入框和发送按钮的容器VIEW
	UIView *_containerView;
	
	//动态伸缩输入框
	HPGrowingTextView *_growingTextView;
	
	//确认发送评论
	UIButton *_sendButton;
	
	//按钮是否处于发送状态，否则处于评论数状态
	BOOL _bIsSendStatus;
	
	//附加栏，包括语音 @好友 表情
	RNPublisherBottomBar *_bottomBar;
	//是否正在使用bottombar
	BOOL _bBottomBarFocus;
	
	//评论类型
	CommentType _commentType;
	
	//默认文案：添加回复
	UILabel *_placeHolderLabel;
	
	
	//评论数标签
	UILabel *_commentCountLabel;
	
	//评论框在底部的时候是否显示评论数目，默认不显示
	BOOL _bIsShowCommentCount;
	
	//评论数
	NSInteger _commentNum;
	
	//评论文字剩余字数限制
	UILabel *_limitWordsLabel;
	
	//最大的评论字数
	NSInteger _LimitWordsNum;
	
	//containerView 最初的y 和 高度
	CGFloat oldY;
	CGFloat oldHeight;
	
	//设置界面风格
	BOOL _isBlackStyle;

	/////网络请求相关//////////
	//发布请求
	RCPublishPost *_publishPost;
	
	//请求参数对
	NSMutableDictionary *_query;
	
	//请求接口
	NSString *_method;
	
	//网络请求（用于请求评论数）
	RCGeneralRequestAssistant *_requestAssistant;
	
	//父UIViewController
	UIViewController *_parentControl;
}
@property(nonatomic,assign)id<RNMiniPublisherDelegate>miniPublisherDelegate;

@property(nonatomic,retain)UIView *containerView;

@property(nonatomic,retain)HPGrowingTextView *growingTextView;

@property(nonatomic,retain)UIButton *sendButton;

@property(nonatomic,retain)RNPublisherBottomBar *bottomBar;

@property(nonatomic,assign)CommentType commentType;

@property(nonatomic,retain)	UILabel *placeHolderLabel;

@property(nonatomic,retain)UILabel *commentCountLabel;

//设置该值，可以控制起始状态是否显示评论数目按钮
@property(nonatomic,assign) BOOL bIsShowCommentCount;

@property(nonatomic,assign)NSInteger commentNum;

@property(nonatomic,retain)	UILabel *limitWordsLabel;

@property(nonatomic,retain)	RCPublishPost *publishPost;

@property(nonatomic,retain)NSMutableDictionary *query;

@property(nonatomic,copy)NSString *method;

@property(nonatomic,retain)RCGeneralRequestAssistant *requestAssistant;

@property(nonatomic,assign)UIViewController *parentControl;
/*
	初始化
	@frame 位置区域
	@andCommentType 评论类型
 */
- (id)initWithFrame:(CGRect)frame andCommentType:(CommentType)commentType;


/*
 初始化
 @frame 位置区域
 @andCommentType 评论类型
 @isBlackStyle 界面风格，默认为白色风格
 */
- (id)initWithFrame:(CGRect)frame andCommentType:(CommentType)commentType isBlackStyle: (BOOL)isBlackStyle;

/*
	设置网络请求参数 每次参数变化的时候要先重置下query
	@query:请求参数对，共有的参数可以不传,具体详见wiki接口说明
	一般的评论只要传入 id：分享的id 
					 user_id：分享所有者的id
 
	调用这个方法之后会主动请求网络更新评论数
 */
- (void)resetQuery:(NSMutableDictionary *)query;

/*
	设置网络请求参数 每次参数变化的时候要先重置下query
	@query:请求参数对，共有的参数可以不传,具体详见wiki接口说明
	一般的评论只要传入 id：分享的id 
	user_id：分享所有者的id
	@commentNum:外部传入的评论数目（将不会主动请求更新评论数目）
 */
- (void)resetQuery:(NSMutableDictionary *)query andCommentCount: (NSInteger)commentNum ;

/*
	重置评论类型
 */
- (void)setCommentType:(CommentType)commentType;

/*
	将整个界面上拉，包括输入框，中间栏，键盘
 */
- (void)pullViewUp;

/*
    将整个输入界面下拉到原来的位置（底部）,一般由superview去调用
 */
- (void)pullViewDown;

/*
	往文本框里面追加文字内容
 */
- (void)inputGrowingText:(NSString*) text;

/*
	设置文本框内容
 */
- (void)setGrowingText:(NSString*) text;

@end
