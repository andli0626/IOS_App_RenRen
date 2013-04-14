//
//  AlbumViewController.h
//  RRSpring
//
//  Created by sheng siglea on 12-3-6.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNWaterFlowView.h"
#import "RCMainUser.h"
#import "RNFileCacheManager.h"
#import "RNModelViewController.h"
#import "RRNextPageFooterView.h"
#import "RNPhotoListModel.h"
#import "RNAlbumItem.h"
#import "RNMiniPublisherView.h"
#import "RNPickPhotoHelper.h"
//#import "RNFeedCommentViewController.h"

/*
 启动来源
 */
typedef enum AlbumStartSource {
    
    //公共主页
    AlbumStartSourcePage = 0,
    //分享
    AlbumStartSourceShare = 1
}AlbumStartSource;

@interface RNAlbumWaterViewController : RNModelViewController<RNWaterFlowViewDelegate,
                                                                    UIScrollViewDelegate,
//                                                                    HummerPageDelegate,
                                                                    UITextFieldDelegate,
RNPickPhotoDelegate,
RNMiniPublisherDelegate>{
   @private
    //瀑布流view
    RNWaterFlowView *_flowView;
    //下一页view
    RRNextPageFooterView *_nextPageFooterView;
    // 被访问相册的用户
    NSNumber *_userId;
    // 被访问相册id
    NSNumber *_albumId;
    // 照片全平动画
    UIScrollView *_fullScreenView;    
    //图片下载引擎                                                                     
    MKNetworkEngine *_networkEngine;
    //照片内容页回调索引                                                                    
    NSInteger _invokeIndex;
    // 带密码的alert
    UIAlertView *_tAlert;
    // 密码输入框
    UITextField *_tInputPassword;
    // 密码输入错误次数
    NSInteger _wrongPwdTimes;
    // 被访问相册详细信息                         
    RNAlbumItem *_albumInfo;
    // 当前登录用户
    RCMainUser *_mainUser;
    //相册内容页面启动来源
    AlbumStartSource _startSource;
    //回复框
    RNMiniPublisherView *_miniPublisherView;
    //网络状态
    NetworkStatus _networkStatus;
    // 从分享进入照片内容页面 分享id
    NSNumber *_shareId;
    // 从分享进入照片内容页面 分享人id
    NSNumber *_shareUid;
    //拍照使用变量
    RNPickPhotoHelper *_iphotocon;
    // 评论列表    
//    RNFeedCommentViewController* viewController;
}

/**
 * 初始化相册内容页面 从个人主页进入
 * @param uid 用户id
 * @param aid 相册id
 */

- (id)initWithUid:(NSNumber *)uid albumId:(NSNumber *)aid;
/**
 * 初始化相册内容页面 从分享进入
 * @param uid 用户id
 * @param aid 相册id
 * @param sid 分享id
 * @param suid 分享者id
 */
- (id)initWithUid:(NSString *)uid albumId:(NSString *)aid shareId:(NSString *)sid shareUid:(NSString *)suid;
/**
 * 初始化相册内容页面 从照片内容页面进入
 * @param  pmodel 照片列表model
 * @param albumItem 相册信息
 */
- (id)initWithPhotoesData:(RNPhotoListModel *)pmodel withAlbum:(RNAlbumItem *)albumItem;
/**
 * 由照片页面进入相册页面,改情况为 分享的单张照片－》照片内容页面 －》相册内容页面
 * 此时 整个相册
 *
 */
- (void)scrollToFlowViewAtIndex:(NSInteger)index;
/*
 * 被滚动
 */
- (void)reloadFlowViewData;
@end
