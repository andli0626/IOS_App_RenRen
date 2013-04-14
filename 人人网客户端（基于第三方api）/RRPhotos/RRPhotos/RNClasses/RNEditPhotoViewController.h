//
//  RNPhotosUploadViewControllerViewController.h
//  RRSpring
//
//  Created by yi chen on 12-3-29.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RNNavigationViewController.h"
#import "RNBaseViewController.h"
#import "RNCreateAlbumViewController.h"
#import "EasyTableView.h"
#import "Filters.h"
typedef enum{
	PhotoUploadTypeNormal,//普通照片上传
	PhotoUploadTypeHead, //头像上传
	
}PhotoUploadType; //照片上传模式

/*
  照片编辑完成回调 
  photoInfo 包括照片要上传的到哪个的相册ID 关键字为: @"id"
 */

@protocol RNEditPhotoFinishDelegate <NSObject>

/**
 * 照片编辑完成回调
 */
- (void)editPhotoFinished:(UIImage *) imageEdited photoInfoDic: (NSDictionary * )photoInfoDic;

/**
 * 照片编辑取消
 */
- (void)editPhotoCancel;

@end

@interface RNEditPhotoViewController : RNBaseViewController<UIActionSheetDelegate,UIGestureRecognizerDelegate,
	UINavigationControllerDelegate,UIImagePickerControllerDelegate,RNCreateAlbumFinishDelegate,
	UITableViewDelegate,UITableViewDataSource,EasyTableViewDelegate>
{
	@private
	Filters *_filters;
	//滤镜效果选中列表
	EasyTableView * _filterTableView;
	//呼出滤镜列表的按钮
	UIButton *_filterButton;
	//效果icons
	NSMutableDictionary *_filterIconsDic;
	//主图片滤镜处理后的图
	NSMutableDictionary *_filterImagesDic;
	
	//上传类型，是普通照片上传还是头像上传
	PhotoUploadType _uploadType;
	//存储当前显示在编辑界面的照片
	UIImageView *_currentImageView;
	//背景剪切框
	UIImageView *_cutPhotoBgView;
	
	//缩放手势
	UIPinchGestureRecognizer *_pinchGesture;
	//双击手势
    UITapGestureRecognizer *_doubleTapGesture;
	//单击手势
    UITapGestureRecognizer *_singleTapGesture;
	//拖动手势
	UIPanGestureRecognizer *_panGesture;
	// 上次pan手势的横坐标
    CGFloat _preLocationX;
	//高清图片
	UIImage* _highQualityImage;
	
	//高清图片的大小
	NSInteger _highQualityLength;
	//滤镜图片
	UIImage *_filterImage;
	//普通图片
	UIImage* _normalQualityImage;
	//普通图片的大小
	NSInteger _normalQualityLength;
	//显示当前照片的大小
	UILabel* _qualityLengthLabel;
			
	//顶部的导航栏
	UIImageView *_topNavView;
	//照片质量切换按钮上面的那个小点
	UIImageView *_slibBarPoiontView;
	//普通文字label
	UILabel *_normalTextLabel;
	//高清文字label
	UILabel *_hdTextLabel;
	//左旋按钮
	UIButton *_photoTurnLeftButton;
	//右旋转
	UIButton *_photoTurnRightButton;
	//工具栏
	UIImageView *_toolBarView;
	//相册选择bar
	UIImageView *_albumSelectBarView;
	//相册名称列表
	UITableView *_albumNameTableView;
	
	//选中的相册ID
	NSString *_albumID;
    //相册名称
    NSString *_albumName;
	//当前选中的相册列表
	UILabel *_albumNameLabel;
	//下拉箭头
	UIImageView *_arrowView;
	//列表是否展开
	BOOL isExpand;
	//是否进入全屏模式
	BOOL isFullScreenMode;
	//图片是否高清
	BOOL isHDPhoto;
	//记录上一次的显示规模
	CGFloat _lastDisplayScale;
	//记录显示矩形框，用于缩放时候的重置位置
	CGRect _lastDisplayFrame;
	CGPoint _gestureStartPoint;
	NSMutableArray *_albumIDArray;
	//编辑完成回调
	id<RNEditPhotoFinishDelegate> _delegate;
	//网络请求
	RCGeneralRequestAssistant *_requestAssistant;
	//记录当前选中的是哪个cell
	NSIndexPath* _oldSelectedIndexPath;
}
@property(nonatomic,retain)Filters *filters;

@property(nonatomic,retain)EasyTableView *filterTableView;

@property(nonatomic,retain)UIButton *filterButton;

@property(nonatomic,retain)UIImageView *currentImageView;

@property(nonatomic,retain)UIImageView *cutPhotoBgView;

@property(nonatomic,retain)UIImage *filterImage;

@property(nonatomic,retain)UIImage *highQualityImage;

@property(nonatomic,retain)UIImage *normalQualityImage;

@property(nonatomic,retain)UILabel *qualityLengthLabel;

@property(nonatomic,retain)UIImageView *topNavView;

@property(nonatomic,retain)UIImageView *slibBarPoiontView;

@property(nonatomic,retain)UILabel *hdTextLabel;

@property(nonatomic,retain)UILabel *normalTextLabel;

@property(nonatomic,retain)UIButton *photoTurnLeftButton;

@property(nonatomic,retain)UIButton *photoTurnRightButton;

@property(nonatomic,retain)UIImageView *toolBarView;

@property(nonatomic,retain)UIImageView *albumSelectBarView;

@property(nonatomic,retain)UITableView *albumNameTableView;

@property(nonatomic,copy)NSString *albumID;

@property(nonatomic,copy)NSString *albumName;

@property(nonatomic,retain)UILabel* albumNameLabel;

@property(nonatomic,retain)UIImageView *arrowView;

@property(nonatomic,retain)NSMutableArray *albumIDArray;

@property(nonatomic,assign)id<RNEditPhotoFinishDelegate> delegate;
 
@property (nonatomic, retain) RCGeneralRequestAssistant *requestAssistant;

@property (nonatomic,retain) NSIndexPath* oldSelectedIndexPath;

/**
 * 设置要编辑的照片
 */
- (void)loadImageToEdit:(UIImage *)editImage;

/**
 * uploadType :默认是普通照片上传
 */
- (id)initWithType: (PhotoUploadType)uploadType; 
 
/**
 * 向指定相册上传照片
 * @param albumId 相册id
 * @param albumName 相册名称
 * @author siglea 
 */
- (id)initWithAlbumId:(NSString *)albumId withAlbumName:(NSString *)albumname;
@end
