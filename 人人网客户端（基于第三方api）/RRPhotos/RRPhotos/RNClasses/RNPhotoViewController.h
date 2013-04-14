//
//  PhotoViewController.h
//  RRSpring
//
//  Created by sheng siglea on 3/21/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//



/*
 启动来源
 */
typedef enum PhotoStartSource {
    //相册内容页面
    PhotoStartSourceAlbum = 0,
    //分享
    PhotoStartSourceShare = 1
}PhotoStartSource;
/*
 * 数据加载状态
 */
typedef enum DataLoadStatus {
    DataLoadStatusReady = 0,
    // 加载当前照片数据中
    DataLoadStatusCurrentPhotoLoading,
    // 加载当前照片完毕
    DataLoadStatusCurrentPhotoFinished,
    // 加载当前照片所在相册信息数据中
    DataLoadStatusAlbumInfoLoading,
    // 加载当前照片所在相册信息数据完毕
    DataLoadStatusAlbumInfoLoaded,
    // 相册数据第一次加载中
    DataLoadStatusAlbumFirstLoading,
    // 相册数据第一次加载完毕
    DataLoadStatusAlbumFirstFinished
}DataLoadStatus;

#import <UIKit/UIKit.h>
#import "RNScrollImageView.h"
#import "MKNetworkKit.h"
#import "RNFileCacheManager.h"
#import "RNPhotoListModel.h"
#import "RCMainUser.h"
#import "RNMiniPublisherView.h"
#import "RNPhotoItem.h"
#import "RNBaseViewController.h"
#import "RNAlbumItem.h"
#import "RNAlbumWaterViewController.h"
#import "RNPublisherViewController.h"
//#import "RNFeedCommentViewController.h"

@class RNQuickViewPhotoCell;
@interface RNPhotoViewController : RNBaseViewController 

                            <UIScrollViewDelegate,
                                UITableViewDelegate,
                                UITableViewDataSource,
                                MBProgressHUDDelegate,
//                                HummerPageDelegate,
                                RNScrollImageViewDelegate,
                                UITextFieldDelegate,
                                RNMiniPublisherDelegate>{
    @private
    //重用ImageView
    NSMutableArray *_arrReusePhotoImageViews;
    //导航
    UIView *_narBarView;
    //返回按钮
    UIButton *_narBarBackBtn;
    //导航标题
    UILabel *_narBarTitleLabel;
    //分享按钮／设置头像按钮
    UIButton *_narBarFirstBtn;
    //下载照片
    UIButton *_narBarDownBtn;
    //更多操作按钮
    UIButton *_navBarMoreBtn;
    //照片滚动view
    UIScrollView *_photosScrollView;
    //NSUInteger 慎用 -- 操作
    NSInteger _currentPhotoIndex;  
    //是否保持索引不变 为解决旋转bug
    BOOL isKeepIndex;
    //当前view 宽
    CGFloat _rWidth;
    //当前view 高
    CGFloat _rHeight;
    //快速预览背景
    UIView *_quickBgView;
    //快速浏览相册照片
    UITableView *_quickTableView;
    //呼出快速浏览按钮
    UIButton *_quickButton;
    //快速预览箭头按钮
    UIImageView *_quickArrImageView;
    //图片下载                                
    MKNetworkEngine *_networkEngine;
    //下载进度圆圈指示                                
//    MBProgressHUD *HUD;
    //照片model
    RNPhotoListModel *_model;
    //照片所有者id
    NSNumber *_userId;
    //照片id 通常是进入照片内容页面第一张照片id
    NSNumber *_photoId;
    // 当前登录用户
    RCMainUser *_mainUser;
    // 分享照片进入获取第一张信息
    RNPhotoItem *_firstPhotoItem;
    // 底部view
    UIView *_bottomView;
    // 发布
    RNMiniPublisherView *_miniPublisherView;
    // 照片描述
    UILabel *_photoDescLable;
    // 浏览评论数
    UILabel *_viewShareCountLable;
    // 定位图标
    UIImageView *_locationImageView;
    // 定位地名
    UIButton *_locationButton;
    // 数据加载状态
    DataLoadStatus _dataLoadStatus;
    // 启动照片内容页面的来源
    PhotoStartSource _startSource;
    // 带密码的alert
    UIAlertView *_tAlert;
    // 密码输入框
    UITextField *_tInputPassword;
    // 密码输入错误次数
    NSInteger _wrongPwdTimes;
    // 被访问相册详细信息                         
    RNAlbumItem *_albumInfo;
    // 当前网络状态
    NetworkStatus _networkStatus;
    // 从分享进入照片内容页面 分享id
    NSNumber *_shareId;
    // 从分享进入照片内容页面 分享人id
    NSNumber *_shareUid;
    // 评论列表                                
//    RNFeedCommentViewController* viewController;
}


/**
 * 从相册内容页面启动
 * @param model 共享photolistmodel
 * @param album 相册信息
 * @param photoIndex 初始照片索引
 */
- (id)initWithPhotoesData:(RNPhotoListModel *)pmodel withAlbum:(RNAlbumItem *)albumItem withPhotoIndex:(NSInteger)index;
/**
 * 从分享页面启动
 * @param 照片的主人id
 * @param 照片id
 * @param sid 分享id
 * @param suid 分享者id
 * @param sourceViewController 触发照片展示的UINavigationController
 */
- (id)initWithUid:(NSString *)uid withPid:(NSString *)pid  shareId:(NSString *)sid shareUid:(NSString *)suid;
@end


/*
 右侧快速浏览tableview cell
 */
@interface RNQuickViewPhotoCell:UITableViewCell
{
    //背景带圆角view
	UIImageView *_bgImageView;
    //内容view
    UIImageView *_contentImageView;
}

@property (nonatomic, retain,readonly) UIImageView *contentImageView;

@end
