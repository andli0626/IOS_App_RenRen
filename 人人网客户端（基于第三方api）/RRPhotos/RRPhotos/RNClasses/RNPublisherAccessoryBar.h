//
//  RNInputAccessoryView.h
//  RRSpring
//
//  Created by 黎 伟 ✪ on 3/12/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//  edit by 玉平 孙 on 3/21/12

#import <UIKit/UIKit.h>
#import "RNView.h"
@protocol RNPublisherAccessoryBarDelegate;

/*注意，次枚举的次序不可随意更改*/
typedef enum PublisherType{
    //发布状态
    EPublishStatusType = 0,
    //上传照片
    EPublishPhotoType,
    //报道
    EPublishReportType,
    //评价
    EPublishEvaluationType,
    //评价地点的回复
	EPublishEvaluationCommentType,
    //分享
    EPublishShareType,
    //收藏
    EPublishFavoritesType,
    //加好友留言
    EPublishAddFriendType,
    //写日志
    EPublishWriteBlogType,
    //回复
    EPublishReplyType,
    //留言
    EPublishGossipType
    
} PublisherType;

@interface RNPublisherAccessoryBar : RNView{
    // 背景
    UIImageView *_backgroundView;
    // 返回按钮
    UIButton *_backButton;
    // 右侧按钮
    UIButton *_rightButton;
    // 标题
    NSString *_title;
    // 标题Label
    UILabel *_titleLabel;
    // 导航条代理
    id<RNPublisherAccessoryBarDelegate> _publisherBarDelegate;
    
    PublisherType _publishState;
}
/*
 * 背景
 */
@property (nonatomic, retain) UIImageView *backgroundView;
/*
 * 返回按钮
 */
@property (nonatomic, readonly) UIButton *backButton;
/*
 * 右侧按钮
 */
@property (nonatomic, retain) UIButton *rightButton;
/*
 * 标题
 */
@property (nonatomic, copy) NSString *title;

/*
 * 标题Label
 */
@property (nonatomic, retain) UILabel *titleLabel;
/*
 * 导航条代理
 */
@property (nonatomic, assign) id<RNPublisherAccessoryBarDelegate> publisherBarDelegate;
/*
 *当前页面状态
 */
@property (nonatomic, assign) PublisherType publishState;


/*
 * 导航条高度
 */
@property (nonatomic, readonly) CGFloat barHeight;

/*
 * 返回按钮是否可用，NO会隐藏返回按钮，默认为YES
 */
@property (nonatomic, assign) BOOL backButtonEnable;
/*
 * 右侧按钮是否可用，NO会隐藏右侧按钮,默认为YES
 */
@property (nonatomic, assign) BOOL rightButtonEnable;


@end

/*
 * 导航条代理
 */
@protocol RNPublisherAccessoryBarDelegate <NSObject>
@optional
/*
 * 点击左边取消按钮
 * 
 */
- (void)publisherAccessoryBarLeftButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar;
/*
 * 点击右边按钮
 * 
 */
- (void)publisherAccessoryBarRightButtonClick:(RNPublisherAccessoryBar *)publisherAccessoryBar;

@end



