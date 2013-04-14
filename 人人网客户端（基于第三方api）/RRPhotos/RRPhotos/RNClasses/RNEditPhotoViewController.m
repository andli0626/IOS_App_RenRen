//
//  RNPhotosUploadViewControllerViewController.m
//  RRSpring
//
//  Created by yi chen on 12-3-29.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RNEditPhotoViewController.h"
#import "AppDelegate.h"
#import "RCBaseRequest.h"
#import "RCMainUser.h"
#import "RCResManager.h"
#import "RCPublishPost.h"
#define ALBUM_TABLE_CELL_HEIGHT 20 //相册选择列表的单元高度
#define ALBUM_TABLE_HEIGHT 300 //相册选择列表的高度
#define MAX_IMAGE_DISPLAY_WIDTH 320 //最大的照片显示区域宽度

#define kImageAdjustMaxWidth 640   //
#define kImageAdjustMaxHeight 640  //照片截取的最大宽度和高度

#define kSlibBarPointMinX 235   //图片切换小点的左右极限坐标
#define kSlibBarPointMaxX 289

//滤镜相关
#define LANDSCAPE_HEIGHT    460
#define LANDSCAPE_WIDTH     320
#define BUTTOM_HEIGHT       70
#define BUTTOM_WIDTH        72
#define ICON_SIZE           50
#define ICON_MARGIN         0
#define ICON_PADDING        5

#define LABEL_VIEW_TAG      10000
#define BORDER_VIEW_TAG     20000
#define ICON_VIEW_TAG       30000

#pragma mark 私有方法
/**
 *	私有方法
 */
@interface RNEditPhotoViewController ()

//网络请求完成
- (void)requestDidSucceed:(NSDictionary *)result ;
//网络请求错误
- (void)requestDidError:(RCError *)error;
//载入图片
-(id)scaleAndRotateImage:(UIImage*) image size:(NSInteger)size  ;
//展示相册列表
- (void)showAlbumTable;
//隐藏相册列表
- (void)hiddenAlbumTable;
//高清普通按钮切换
- (void)onClickSwitchButton;
//调整图片到中心
- (void)ajustImageViewCenter;
//显示照片
- (void)displayCurrentView;
//获取截取区域的照片内容
- (UIImage *)imageInAdjustArea;

@end


@implementation RNEditPhotoViewController
@synthesize filters = _filters;
@synthesize filterTableView = _filterTableView;
@synthesize filterButton = _filterButton;
@synthesize currentImageView = _currentImageView;
@synthesize cutPhotoBgView = _cutPhotoBgView;
@synthesize filterImage = _filterImage;
@synthesize highQualityImage = _highQualityImage;
@synthesize normalQualityImage = _normalQualityImage;
@synthesize qualityLengthLabel = _qualityLengthLabel;
@synthesize topNavView = _topNavView;
@synthesize slibBarPoiontView = _slibBarPoiontView;
@synthesize hdTextLabel = _hdTextLabel;
@synthesize normalTextLabel = _normalTextLabel;
@synthesize photoTurnLeftButton = _photoTurnLeftButton;
@synthesize photoTurnRightButton = _photoTurnRightButton;
@synthesize toolBarView = _toolBarView;
@synthesize albumSelectBarView = _albumSelectBarView;
@synthesize albumNameTableView = _albumNameTableView;
@synthesize albumID = _albumID;
@synthesize albumName = albumName;
@synthesize albumNameLabel = _albumNameLabel;
@synthesize arrowView = _arrowView;
@synthesize albumIDArray = _albumIDArray;
@synthesize delegate = _delegate;
@synthesize requestAssistant = _requestAssistant;
@synthesize oldSelectedIndexPath = _oldSelectedIndexPath;

#pragma mark -方法

- (void)dealloc{
	self.filters = nil;
	self.filterTableView = nil;
	self.filterButton = nil;
	self.currentImageView  = nil;
	self.cutPhotoBgView = nil;
	self.highQualityImage = nil;
	self.normalQualityImage = nil;
	self.qualityLengthLabel = nil;
	self.topNavView = nil;
	self.slibBarPoiontView = nil;
	self.hdTextLabel = nil;
	self.normalTextLabel = nil;
	self.photoTurnLeftButton = nil;
	self.photoTurnRightButton = nil;
	self.toolBarView = nil;
	self.albumNameTableView = nil;
	self.albumID = nil;
    self.albumName = nil;
	self.albumSelectBarView = nil;
	self.albumNameLabel = nil;
	self.arrowView = nil;
	self.albumIDArray = nil;
	self.delegate = nil;
	self.requestAssistant = nil;
	
	TT_RELEASE_SAFELY(_doubleTapGesture);
	TT_RELEASE_SAFELY(_singleTapGesture);
	TT_RELEASE_SAFELY(_pinchGesture);
	TT_RELEASE_SAFELY(_panGesture);
	[super dealloc];
}

/**
 * uploadType :默认是普通照片上传
 */
- (id)initWithType: (PhotoUploadType)uploadType{
	_uploadType = uploadType;
	if (self = [self init]) {
		self.albumName = @"头像相册";
	}
	return  self;
}

/**
 * 向指定相册上传照片
 * @param albumId 相册id
 * @param albumName 相册名称
 * @author siglea 
 */
- (id)initWithAlbumId:(NSString *)albumId withAlbumName:(NSString *)albumname{
    if (self = [self init]) {
        self.albumID = albumId;
        self.albumName = albumname;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
	
		//默认是非全屏浏览模式
		isFullScreenMode = NO;
		
		//默认是没有展开相册列表
		isExpand = NO;
		
		//网络请求初始化
		self.requestAssistant = [RCGeneralRequestAssistant requestAssistant];
		self.requestAssistant.onCompletion = ^(NSDictionary* result){
			[self requestDidSucceed:result];
		};
		self.requestAssistant.onError = ^(RCError* error) {
			[self requestDidError:error];
		};
				
		//相册列表数组
		_albumIDArray= [[NSMutableArray alloc]initWithCapacity:1000];
		
		UIImageView *currentImageView = [[UIImageView alloc ]init];
		self.currentImageView = currentImageView;
		TT_RELEASE_SAFELY(currentImageView);

    }
    return self;
}

/*
 * 从外部导入要编辑的图片
 */
- (void)loadImageToEdit:(UIImage *)editImage{
	NSLog(@"cy -------- 原始图片的高：%f 宽：%f",editImage.size.height, editImage.size.width);
	//载入高清图片
//	self.highQualityImage = [editImage scaleWithMaxSize:1024];
//	self.highQualityImage = [self scaleAndRotateImage:editImage size:1024];
//	self.highQualityImage = [editImage scaleToSize:CGSizeMake(640, 640)];
	self.highQualityImage = [editImage resizedImage:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationMedium];

//	CGFloat originHeight = editImage.size.height;
//	CGFloat originWidth = editImage.size.width;
	
	
	_highQualityLength = [UIImageJPEGRepresentation(_highQualityImage, 1.0f) length];
	
	//载入普通图片
//	UIImage* lowimg = [editImage scaleWithMaxSize:516];
//	UIImage* lowimg = [self scaleAndRotateImage:editImage size:640];
//	lowimg = [editImage scaleToSize:CGSizeMake(640, 640)];
	UIImage	*lowimg = [editImage resizedImage:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationMedium];
	NSData* data = UIImageJPEGRepresentation(lowimg, 1.0f);
	
	_normalQualityLength = [data length];
	self.normalQualityImage = [UIImage imageWithData:data];
	
	//准备缩略图
	[self prepareIcomForFilte:self.normalQualityImage];
}


#pragma mark - 显示照片  加载界面
/* 
	显示当前要编辑的照片,加载整个界面的视图
 */
- (void)displayCurrentView{
	
	if(nil == self.highQualityImage){
		return;
	}
	
	CGFloat image_w = self.highQualityImage.size.width;
	CGFloat image_h = self.highQualityImage.size.height;
	NSLog(@"原高清图片的 宽度：%f 高度 %f",image_w,image_h);
	NSLog(@"普通清晰图的 宽度：%f 高度 %f",self.normalQualityImage.size.width ,self.normalQualityImage.size.height);
	CGFloat newImageWidth = image_w ;
	CGFloat newImageHeigth = image_w;

	if (image_w > image_h && image_h > MAX_IMAGE_DISPLAY_WIDTH) {
		newImageHeigth = MAX_IMAGE_DISPLAY_WIDTH;//宽度设为最大的显示
		newImageWidth = newImageHeigth / image_h * image_w; 
	}else if (image_w > MAX_IMAGE_DISPLAY_WIDTH){
		newImageWidth = MAX_IMAGE_DISPLAY_WIDTH;
		newImageHeigth = newImageWidth / image_w * image_h;
	}

	CGRect viewFrame = CGRectMake(160 - newImageWidth / 2, 230 - newImageHeigth / 2,
								   newImageWidth, newImageHeigth);
	_lastDisplayFrame = viewFrame;//记录最近一次的显示矩形框
	
	[self.view removeAllSubviews];//先移除，否则会被覆盖
	//主照片

	self.currentImageView.frame = viewFrame;
	[self.view addSubview:self.currentImageView];
	UIImage *cutPhotoBgImage = [[RCResManager getInstance]imageForKey:@"cutPhotoFrame"];
	UIImageView *cutPhotoBgView = [[UIImageView alloc]initWithImage:[cutPhotoBgImage 
																	 stretchableImageWithLeftCapWidth:1 
																	 topCapHeight:1]];
	
	CGRect imgframe;
	if(newImageWidth < newImageHeigth){
		imgframe = CGRectMake(160 - newImageWidth/2, 230-newImageWidth/2 , newImageWidth, newImageWidth);
	} else {
		imgframe = CGRectMake(160 - newImageHeigth/2, 230-newImageHeigth/2 , newImageHeigth, newImageHeigth);
	}
	cutPhotoBgView.frame = imgframe;
	[self.view addSubview:cutPhotoBgView];
	self.cutPhotoBgView = cutPhotoBgView;
	TT_RELEASE_SAFELY(cutPhotoBgView);
	
	//灰色边界
	UIView* outofCutv1 = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 320, imgframe.origin.y + 20)];
	outofCutv1.backgroundColor = [UIColor blackColor];
	outofCutv1.alpha = 0.4;
	[self.view addSubview:outofCutv1];
	[outofCutv1 release];
	
	UIView* outofCutv2 = [[UIView alloc] initWithFrame:CGRectMake(0, imgframe.origin.y, imgframe.origin.x, 
																  imgframe.size.height)];
	outofCutv2.backgroundColor = [UIColor blackColor];
	outofCutv2.alpha = 0.4;
	[self.view addSubview:outofCutv2];
	[outofCutv2 release];
	
	UIView* outofCutv3 = [[UIView alloc] initWithFrame: CGRectMake(imgframe.origin.x+imgframe.size.width,
																   imgframe.origin.y, 
																   320-imgframe.origin.x-imgframe.size.width,
																   imgframe.size.height)];
	outofCutv3.backgroundColor = [UIColor blackColor];
	outofCutv3.alpha = 0.4;
	[self.view addSubview:outofCutv3];
	[outofCutv3 release];
	
	UIView* outofCutv4 = [[UIView alloc] initWithFrame:CGRectMake(0,
																  imgframe.origin.y+imgframe.size.height, 
																  320, 
																  460-imgframe.origin.y-imgframe.size.height)];
	outofCutv4.backgroundColor = [UIColor blackColor];
	outofCutv4.alpha = 0.4;
	[self.view addSubview:outofCutv4];
	[outofCutv4 release];

	if (self.currentImageView != nil) {
		[self.currentImageView removeGestureRecognizer:_pinchGesture];
		[self.currentImageView removeGestureRecognizer:_doubleTapGesture];
		[self.currentImageView removeGestureRecognizer:_singleTapGesture];

	}
	
	[self.view addSubview:self.topNavView]; 
	[self.view addSubview:self.albumNameTableView];
	[self.view addSubview:self.albumSelectBarView];
	[self.view addSubview:self.toolBarView];
	self.toolBarView.hidden = YES; //测试用
	
	[self.view addSubview:self.filterTableView];
	
	self.currentImageView.frame = viewFrame;
	if (!self.filterImage ) {
		self.filterImage = self.highQualityImage;
	}
	if (self.currentImageView.image != self.filterImage) {
		if (self.filterImage) {
			self.currentImageView.image = self.filterImage;//加载滤镜图片
		}
	}
	
	//加入当前照片的手势
	self.currentImageView.userInteractionEnabled = YES;    //允许用户交互
	[self.currentImageView addGestureRecognizer:_pinchGesture];//添加图片点击手势，做全屏浏览处理
	[self.currentImageView addGestureRecognizer:_singleTapGesture];
	[self.currentImageView addGestureRecognizer:_doubleTapGesture];
}
#pragma mark - 点击事件
- (void)onClickConcelButton{
	//点击取消按钮
//	if (self.navigationController) { //如果页面是push出来的
//		[self.navigationController popViewControllerAnimated:YES];
//	}else { //如果是present出来的
//		[self dismissModalViewControllerAnimated:YES];
//	}
	
	if ([self.delegate respondsToSelector:@selector(editPhotoCancel)]) {
		[self.delegate editPhotoCancel];
	}
}

/*
 *	获取截取区域内的照片内容
 */
- (UIImage *)imageInAdjustArea{
	
	CGFloat cx;
    CGFloat cy;
    CGFloat cw;
    
    CGFloat scale = self.currentImageView.width / _lastDisplayFrame.size.width;
    if(_lastDisplayFrame.size.height > _lastDisplayFrame.size.width){
		cx = (self.cutPhotoBgView.origin.x - self.currentImageView.origin.x) / scale ;
        cy = (self.cutPhotoBgView.origin.y - self.currentImageView.origin.y)  / scale ;
        cw = _lastDisplayFrame.size.width / scale;
    } else {
		cx = (self.cutPhotoBgView.origin.x - self.currentImageView.origin.x)  / scale ;
        cy = (self.cutPhotoBgView.origin.y - self.currentImageView.origin.y)  / scale ;
        cw = _lastDisplayFrame.size.height / scale;
    }
	
	CGFloat scale1 ; //比例换算到原图
	if (isHDPhoto) {
		scale1 = self.highQualityImage.size.width / _lastDisplayFrame.size.width;
	}else{
		scale1 = self.normalQualityImage.size.width / _lastDisplayFrame.size.width;
	}
	cx *= scale1;
	cy *= scale1;
	cw *= scale1;
	
    CGRect cropRect = CGRectMake(cx, cy, cw, cw);
    NSLog(@"cy ---------- cropRect: %f %f %f %f", cx,cy,cw,cw);
    NSLog(@"--- currentImageView.image.size: %@", NSStringFromCGSize(self.currentImageView.image.size));
	
	//	if ( _uploadType == PhotoUploadTypeHead) {
	UIImage *result;
	CGImageRef imageRef;
	
//	if(isHDPhoto){
//		imageRef = CGImageCreateWithImageInRect([[self.currentImageView image] CGImage], cropRect);
//		result = [UIImage imageWithCGImage:imageRef];	
//	} else {
//		imageRef = CGImageCreateWithImageInRect([[self.currentImageView image] CGImage], cropRect);
//		result = [UIImage imageWithCGImage:imageRef];
//	}
	imageRef = CGImageCreateWithImageInRect([self.highQualityImage CGImage], cropRect);
	result = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	NSLog(@"--- new.photo.size: %@", NSStringFromCGSize(result.size));
	
	result = [result resizedImage:CGSizeMake(640, 640)
		interpolationQuality:kCGInterpolationMedium];
	NSLog(@"--- new.photo.size: %@", NSStringFromCGSize(result.size));
	return result;
}


/*
 * 确认按钮点击，回调传回数据，包括照片数据，选中的相册ID
 */
- (void)onClickConfirmButton{
	
	//传回照片数据
	NSMutableDictionary *photoInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
	
	if (self.albumID) {
		[photoInfoDic setObject:self.albumID forKey:@"id"]; //传回选中的相册ID
	}

	//传回头像数据
	if(self.delegate && [self.delegate respondsToSelector:@selector(editPhotoFinished:photoInfoDic:)]) {
		[self.delegate editPhotoFinished:self.filterImage photoInfoDic:photoInfoDic];
	}
	
	RCPublishPost *publishPost = [[RCPublishPost alloc]init ];
	NSMutableDictionary *dics = [NSMutableDictionary dictionaryWithCapacity:5];
	[dics setObject:@"test" forKey:@"caption" ];
	[publishPost publishPostWith:self.filterImage paramDic:dics withMethod:@"photos/uploadbin"];
	TT_RELEASE_SAFELY(publishPost);
	
		
//	}else{
//		if (self.filterImage) {
//			if(self.delegate && [self.delegate respondsToSelector:@selector(editPhotoFinished:photoInfoDic:)]) {
//				[self.delegate editPhotoFinished:self.filterImage photoInfoDic:photoInfoDic];
//			}
//		}
//		
//		RCPublishPost *publishPost = [[RCPublishPost alloc]init ];
//		NSMutableDictionary *dics = [NSMutableDictionary dictionaryWithCapacity:5];
//		[dics setObject:@"test" forKey:@"caption" ];
//		[publishPost publishPostWith:self.filterImage paramDic:dics withMethod:@"photos/uploadbin"];
//		TT_RELEASE_SAFELY(publishPost);
//	}
	
	if (self.navigationController) { //如果页面是push出来的

	}else { //如果是present出来的
		[self dismissModalViewControllerAnimated:YES];
	}
}

/*
 * 旋转照片操作
 */
- (void)onClickTurnLeftButton{
	//点击左旋转图片按钮
	self.highQualityImage = [self.highQualityImage imageRotated:self.highQualityImage andByDegrees:-90];
	self.normalQualityImage = [self.normalQualityImage imageRotated:self.normalQualityImage andByDegrees:-90];
	[self displayCurrentView];
}

/**
 * 右边旋转操作
 */
- (void)onClickTurnRightButton{
	//点击右旋转图片按钮
	self.highQualityImage = [self.highQualityImage imageRotated:self.highQualityImage andByDegrees:90];
	self.normalQualityImage = [self.normalQualityImage imageRotated:self.normalQualityImage andByDegrees:90];
	[self displayCurrentView];
}

/**
 * 拖动高清普通切换的小点
 */
- (void)onPanSwitchPoint:(UIPanGestureRecognizer *)panGesture{
	CGPoint translation = [panGesture translationInView:self.toolBarView];
//    CGPoint velocity = [panGesture velocityInView:self.view];
	CGFloat diffX = translation.x - _preLocationX;
	NSLog(@"chenyi -------paning ------- %f ",translation.x);

	CGFloat newX = self.slibBarPoiontView.left + diffX;
	if (newX > kSlibBarPointMaxX) {
		self.slibBarPoiontView.left = kSlibBarPointMaxX;
	}else if (newX < kSlibBarPointMinX) {
		self.slibBarPoiontView.left = kSlibBarPointMinX;
	}else {
		self.slibBarPoiontView.left = newX;
	}
	
	if (panGesture.state == UIGestureRecognizerStateEnded) {
        _preLocationX = 0;
		if (self.slibBarPoiontView.left > (kSlibBarPointMinX + kSlibBarPointMaxX ) / 2) {
			[UIView animateWithDuration:0.1 animations:^(){
				self.slibBarPoiontView.left = kSlibBarPointMaxX;
			} completion:^(BOOL finished){
				if (finished) {
					isHDPhoto = YES; //图片质量切换
					[self setSlibBarApearance];
					[self displayCurrentView];

				}
			}];
			
		}else {
			[UIView animateWithDuration:0.1 animations:^(){
				self.slibBarPoiontView.left = kSlibBarPointMinX;
			} completion:^(BOOL finished){
				if (finished) {
					isHDPhoto = NO; //图片质量切换
					[self setSlibBarApearance];
					[self displayCurrentView];

				}
			}];
		}
	}else {
        _preLocationX = translation.x;
    }
}
/*
	改变图片质量切换bar的一些外观
 */
- (void)setSlibBarApearance{
	if (!isHDPhoto) {
		self.normalTextLabel.textColor = RGBCOLOR(222, 222, 222); //设置标签选中颜色
		self.hdTextLabel.textColor = RGBCOLOR(138, 138, 138);
	}else {
		self.hdTextLabel.textColor = RGBCOLOR(222, 222, 222); //改变两个标签的颜色，标记选中状态
		self.normalTextLabel.textColor = RGBCOLOR(138, 138, 138);
	}
	
	[UIView animateWithDuration:1 animations:^(){//显示图片大小
		if (!isHDPhoto) {
			float l = _normalQualityLength / 1024.0;
			if (l > 1024 ) {
				self.qualityLengthLabel.text = [NSString stringWithFormat:
												NSLocalizedString(@"图片大小：%.2fM", @"图片大小：%.2fM"),l / 1024]; 
			}else {
				self.qualityLengthLabel.text = [NSString stringWithFormat:
												NSLocalizedString(@"图片大小：%.2fK", @"图片大小：%.2fK"),l]; 
			}
		}else {
			float l = _highQualityLength / 1024.0;
			if (l > 1024 ) {
				self.qualityLengthLabel.text = [NSString stringWithFormat:
												NSLocalizedString(@"图片大小：%.2fM", @"图片大小：%.2fM") ,l / 1024]; 
			}else {
				self.qualityLengthLabel.text = [NSString stringWithFormat:
												NSLocalizedString(@"图片大小：%.2fK", @"图片大小：%.2fK") ,l]; 
			} 
		}
		self.qualityLengthLabel.alpha = 0.6;
	} completion:^(BOOL finished){
		if (finished) { 
			[UIView animateWithDuration:1 animations:^(){
//				self.qualityLengthLabel.alpha = 0.0f;
			}];
		}
		
	}];
}

/**
 * 切换照片质量
 */
- (void)onClickSwitchButton{
	isHDPhoto = ! isHDPhoto; //图片质量切换
	if (!isHDPhoto) { 
		[UIView animateWithDuration:0.2 animations:^(){
			self.slibBarPoiontView.frame = CGRectMake(kSlibBarPointMinX, 24, _slibBarPoiontView.image.size.width, 
													  _slibBarPoiontView.image.size.height);
		}];
		
	}else {
		[UIView animateWithDuration:0.2 animations:^(){
			self.slibBarPoiontView.frame = CGRectMake(kSlibBarPointMaxX, 24, _slibBarPoiontView.image.size.width, 
													  _slibBarPoiontView.image.size.height);
		}];
	}
	[self setSlibBarApearance]; //改变外观
	[self displayCurrentView];
}

/**
 *	点击选中相册条
 */
- (void)tapAlbumSelectBar{
	
	//发送网络请求相册列表
	if (!isExpand && [self.albumIDArray count] == 0 ) { //如果数据为空，并且没有展开，则发网络请求
		RCMainUser *mainUser = [RCMainUser getInstance];
		NSMutableDictionary *dics = [NSMutableDictionary dictionaryWithCapacity:10];
		if (mainUser.sessionKey) {
			[dics setObject:mainUser.sessionKey forKey:@"session_key"];
			[dics setObject:mainUser.userId forKey:@"uid"];
			[dics setObject:[NSNumber numberWithInt:1600] forKey:@"page_size"];
            [dics setObject:[NSNumber numberWithInt:1] forKey:@"all_album"];
			[self.requestAssistant sendQuery:dics withMethod:@"photos/getAlbums"];
		}
	}else if (!isExpand ) { //如果有数据，直接展示
		[self showAlbumTable];
	}else { //如果已经展开，那么直接收缩
		[self hiddenAlbumTable];
	}
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
	
	return YES;
}


#pragma  mark - 图片双击 则重置位置到中心
- (void)doubletapCurrentImage{
	[UIView animateWithDuration:0.5 animations:^(){
		[self ajustImageViewCenter];
		
	}];
}

#pragma  mark - 图片单击 进入全屏浏览模式
- (void)tapCurrentImage{
	return; //测试不允许隐藏
	
	if (isExpand) { //如果已经展开了不允许隐藏
		return;
	}
	
	isFullScreenMode = !isFullScreenMode;
	
	[UIView beginAnimations:@"aa" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	if(isFullScreenMode)
	{		
		[[UIApplication sharedApplication] setStatusBarHidden:isFullScreenMode withAnimation:UIStatusBarAnimationSlide];
		CGRect r =	self.topNavView.frame;
		r.origin.y -= (20 + self.topNavView.height);
		self.topNavView.frame = r;
		
		r = self.albumSelectBarView.frame;
		r.origin.y -= (64 + r.size.height);
		self.albumSelectBarView.frame = r;
		
		r = self.toolBarView.frame;
		r.origin.y += (44 + self.qualityLengthLabel.height);
		self.toolBarView.frame = r;
		
	}
	else 
	{
		self.navigationController.navigationBar.hidden = NO;
		
		[[UIApplication sharedApplication] setStatusBarHidden:isFullScreenMode withAnimation:UIStatusBarAnimationSlide];
		CGRect r =	self.topNavView.frame;
		r.origin.y += (20 + self.topNavView.height);
		self.topNavView.frame = r;
		
		r = self.albumSelectBarView.frame;
		r.origin.y += (64 + r.size.height);
		self.albumSelectBarView.frame = r;
		
		r = self.toolBarView.frame;
		r.origin.y -= (44 + self.qualityLengthLabel.height);
		self.toolBarView.frame = r;
		
	}
	[UIView commitAnimations];
}

- (UIButton *)photoTurnLeftButton{
	if (!_photoTurnLeftButton) {
		//旋转照片按钮
		_photoTurnLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_photoTurnLeftButton setImage:[[RCResManager getInstance]imageForKey:@"turn_icon" ]
								  forState:UIControlStateNormal];
		_photoTurnLeftButton.frame = CGRectMake(27, 0, [_photoTurnLeftButton currentImage].size.width, 
													[_photoTurnLeftButton currentImage].size.height);
		[_photoTurnLeftButton addTarget:self action:@selector(onClickTurnLeftButton) //点击旋转图片
						   forControlEvents:UIControlEventTouchUpInside];

	}
	return _photoTurnLeftButton;
}

- (UIButton *)photoTurnRightButton{
	if (!_photoTurnRightButton) {
		_photoTurnRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *rightButtonBGImage = [[RCResManager getInstance]imageForKey:@"turn_icon" ];
		rightButtonBGImage = [rightButtonBGImage rotate:UIImageOrientationRightMirrored]; 
		[_photoTurnRightButton setImage:rightButtonBGImage	forState:UIControlStateNormal];
	
		_photoTurnRightButton.frame = CGRectMake(80, 0, [_photoTurnRightButton currentImage].size.width, 
												 [_photoTurnRightButton currentImage].size.height);
		[_photoTurnRightButton addTarget:self action:@selector(onClickTurnRightButton) //点击旋转图片
						forControlEvents:UIControlEventTouchUpInside];

	}
	return _photoTurnRightButton;
}

- (UIImageView *)topNavView{
	
	if (!_topNavView) {
		//导航栏的背景
		UIImageView *topView = [[UIImageView alloc]initWithImage:[[RCResManager getInstance]imageForKey:@"title_bar"]];
		topView.userInteractionEnabled = YES;
		topView.frame = CGRectMake(0, 0, 320, 44);
		_topNavView = topView;
		
		//返回按键
		UIButton* concelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[concelButton setImage:[[RCResManager getInstance]imageForKey:@"titlebar_cancel"]  
					  forState:UIControlStateNormal];
		CGSize buttonSize = [concelButton currentImage].size;
		concelButton.frame = CGRectMake(5, 0, buttonSize.width	,buttonSize.height);
		[concelButton addTarget:self action:@selector(onClickConcelButton) 
			   forControlEvents:UIControlEventTouchUpInside];
		[_topNavView addSubview:concelButton];
		
		//确认按钮
		UIButton* confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[confirmButton setImage:[[RCResManager getInstance]imageForKey:@"titlebar_confirm"] 
					   forState:UIControlStateNormal];
		CGSize confirmButtonSize = [confirmButton currentImage].size;
		confirmButton.frame = CGRectMake(270, 0, confirmButtonSize.width, confirmButtonSize.height);
		[confirmButton addTarget:self action:@selector(onClickConfirmButton) 
				forControlEvents:UIControlEventTouchUpInside];
		[_topNavView addSubview:confirmButton];
		
		//标题栏
		UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(59, 8, 137, 28)];
		[titleLabel setBackgroundColor: [UIColor clearColor]];
		[titleLabel setTextColor:RGBCOLOR(255, 255, 255)];
		[titleLabel setShadowOffset:CGSizeMake(0, -2)]; 
		[titleLabel setShadowColor:RGBACOLOR(0, 0, 0, 0.3)];//阴影颜色及alpha
		[titleLabel setFont:[UIFont fontWithName:MED_HEITI_FONT size:20]];
		[titleLabel setText:NSLocalizedString(@"编辑照片", @"编辑照片")];
		[_topNavView addSubview:titleLabel];
		[titleLabel release];

	}
	return _topNavView;
}

- (UILabel *)hdTextLabel{
	if (!_hdTextLabel) {
		//文字 高清
		_hdTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(285, 5, 30, 25)];
		_hdTextLabel.backgroundColor = [UIColor clearColor];
		_hdTextLabel.textColor = RGBCOLOR(222, 222, 222);
		_hdTextLabel.text = @"高清";
		_hdTextLabel.font = [UIFont fontWithName: LIGHT_HEITI_FONT size:12];
		_hdTextLabel.shadowColor = RGBACOLOR(0, 0, 0,0.75);
		_hdTextLabel.shadowOffset = CGSizeMake(0, -2);
	}
	return _hdTextLabel;
}

- (UILabel *)normalTextLabel{
	if (!_normalTextLabel) {
		//文字 普通
		_normalTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(235, 5, 30, 25)];
		_normalTextLabel.backgroundColor = [UIColor clearColor];
		_normalTextLabel.textColor = RGBCOLOR(138, 138, 138);
		_normalTextLabel.text = @"普通";
		_normalTextLabel.font = [UIFont fontWithName: LIGHT_HEITI_FONT size:12];
		_normalTextLabel.shadowColor = RGBACOLOR(0, 0, 0,0.75);
		_normalTextLabel.shadowOffset = CGSizeMake(0, -2);
	}
	return _normalTextLabel;
}

//
// 图片大小标签
//
- (UILabel*)qualityLengthLabel{
	if (!_qualityLengthLabel) {
		//图片大小文字
		_qualityLengthLabel = [[UILabel alloc]initWithFrame:CGRectMake(0 , -20, PHONE_SCREEN_SIZE.width, 20)];
		_qualityLengthLabel.backgroundColor = [UIColor blackColor];
		_qualityLengthLabel.alpha = 0.0;
		_qualityLengthLabel.font = [UIFont systemFontOfSize:12];
		_qualityLengthLabel.textColor =	[UIColor whiteColor];
		_qualityLengthLabel.textAlignment = UITextAlignmentCenter;
		if (_highQualityLength / 1024.0 > 1024) { //如果大于1024K 则换算成M
			_qualityLengthLabel.text = [NSString stringWithFormat:@"图片大小：%.2fM",_highQualityLength / 1024.0 / 1024];
		}else {
			_qualityLengthLabel.text = [NSString stringWithFormat:@"图片大小：%.2fK",_highQualityLength / 1024.0];
		}
	}
	return _qualityLengthLabel;
}

//
// 底部工具栏
//
- (UIImageView *)toolBarView{
	if (!_toolBarView) {
		//工具栏
		_toolBarView = [[[UIImageView alloc]initWithImage:
						 [[RCResManager getInstance]imageForKey:@"button_bar"]]autorelease];
		_toolBarView.frame = CGRectMake(0, 480 - 44 - 20, 320, 44);
		_toolBarView.userInteractionEnabled = YES;

		//照片质量切换控件
		UIButton *photoQualitySwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[photoQualitySwitchButton setImage:[[RCResManager getInstance]imageForKey:@"slid_bar"] forState:UIControlStateNormal];
		photoQualitySwitchButton.frame  = CGRectMake(239, 24, photoQualitySwitchButton.currentImage.size.width,
													 photoQualitySwitchButton.currentImage.size.height);
		[_toolBarView addSubview:photoQualitySwitchButton];

		//质量切换上面的小点
		_slibBarPoiontView = [[UIImageView alloc]initWithImage:[[RCResManager getInstance]imageForKey:@"slid_point"]];
		self.slibBarPoiontView.frame = CGRectMake((isHDPhoto ? kSlibBarPointMaxX : kSlibBarPointMinX), 
												  24, 
												  _slibBarPoiontView.image.size.width, 
												  _slibBarPoiontView.image.size.height);
		_slibBarPoiontView.userInteractionEnabled = YES;
		
		[_toolBarView addSubview:self.photoTurnLeftButton]; //左旋转添加到工具栏
		[_toolBarView addSubview:self.photoTurnRightButton]; //右旋转添加到工具栏
		[_toolBarView addSubview:self.slibBarPoiontView];
		[_toolBarView addSubview:self.hdTextLabel];
		[_toolBarView addSubview:self.normalTextLabel];
		[_toolBarView addSubview:self.qualityLengthLabel];
		
		//为了方便拖动在上面盖一层透明蒙版
		UIButton *panView = [[UIButton alloc]initWithFrame:CGRectMake(239, 
																  0, 
																 _toolBarView.width - 239,
																 _toolBarView.height)];
		
		[panView addTarget:self action:@selector(onClickSwitchButton) 
						   forControlEvents:UIControlEventTouchUpInside];
		panView.backgroundColor = [UIColor clearColor];
		
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self 
                                                                                     action:@selector(onPanSwitchPoint:)];
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 1;
        panGesture.delegate = self;
		_panGesture = panGesture;
		panView.userInteractionEnabled = YES;
		
		[panView addGestureRecognizer:panGesture];
		[self.toolBarView addSubview:panView];
		TT_RELEASE_SAFELY(panGesture);
	}
	return _toolBarView;
}

- (UILabel *)albumNameLabel{
	
	if (!_albumNameLabel) {
		_albumNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 6, 275, 20)];
		[_albumNameLabel setBackgroundColor:[UIColor clearColor]];
		[_albumNameLabel setTextColor:RGBCOLOR(255, 255, 255)];
		[_albumNameLabel setShadowColor:RGBACOLOR(0, 0, 0, 0.75)];
		[_albumNameLabel setShadowOffset:CGSizeMake(0, 2)];
		[_albumNameLabel setFont:[UIFont fontWithName:MED_HEITI_FONT size:15]];
		[_albumNameLabel setText:[NSString stringWithFormat:
								  NSLocalizedString(@"上传相册：%@", @"上传相册：%@") ,self.albumName ? self.albumName : @""]];

	}
	return _albumNameLabel;
}

- (UIImageView *)albumSelectBarView{
	if(!_albumSelectBarView){
		_albumSelectBarView = [[UIImageView alloc]initWithImage:[[RCResManager getInstance]
																 imageForKey:@"album_selected_bar"]];
		_albumSelectBarView.frame = CGRectMake(0, CONTENT_NAVIGATIONBAR_HEIGHT, 320, 
												   _albumSelectBarView.image.size.height - 5  );
		_albumSelectBarView.layer.masksToBounds = YES;
		_albumSelectBarView.alpha = 0.8;
		if (self.albumID == nil && _uploadType != PhotoUploadTypeHead) {//如果已指定相册或者上传头像 不需要选择相册
			_albumSelectBarView.userInteractionEnabled = YES;//允许使用手势点击
			UITapGestureRecognizer *albumNameTapGesture = [[UITapGestureRecognizer alloc]
														   initWithTarget:self  
														   action:@selector(tapAlbumSelectBar)];
			[albumNameTapGesture setNumberOfTapsRequired:1];
			[_albumSelectBarView addGestureRecognizer:(albumNameTapGesture)];//添加图片点击手势，做全屏浏览处理
			[albumNameTapGesture release];
		
			//下拉箭头
			_arrowView = [[UIImageView alloc]initWithImage:[[RCResManager getInstance]imageForKey:@"pull_arrow"]];
			self.arrowView.frame = CGRectMake(293, 9, _arrowView.image.size.width,_arrowView.image.size.height);
			//			self.arrowView.frame = CGRectMake(180, 9, _arrowView.image.size.width,_arrowView.image.size.height);
			[_albumSelectBarView addSubview:self.arrowView];
			
			//默认是手机相册
			self.albumName = @"手机相册";
		}
		//相册名称
		[self.albumSelectBarView addSubview:self.albumNameLabel];

	}
	return _albumSelectBarView;
}

/**
 *	相册名称下拉列表
 */
- (UITableView *)albumNameTableView{
	if (!_albumNameTableView) {
		//相册列表 
		_albumNameTableView = [[UITableView alloc]initWithFrame:
							   CGRectMake(0,44 + self.albumSelectBarView.frame.size.height	, 320, 0)
														  style:UITableViewStylePlain];
		_albumNameTableView.showsVerticalScrollIndicator = NO;//隐藏滚动条
		_albumNameTableView.bounces = NO;//不允许反向拖动
		_albumNameTableView.separatorStyle = UITableViewCellSeparatorStyleNone;//设置无分割线
		_albumNameTableView.hidden = NO;
		_albumNameTableView.delegate  = self;
		_albumNameTableView.dataSource = self;
	}
	return _albumNameTableView;
}

/**
 *	滤镜数据
 */
- (Filters *)filters{
	
	if (!_filters) {
		_filters = [[Filters alloc] init];
	}
	return _filters;
}
/**
 * 图片滤镜效果选择列表
 */
- (EasyTableView *)filterTableView {
	if (!_filterTableView) {
		// add filterList
		// filterChooserBackground.png
		
		CGRect frameRect = CGRectMake(0,
									  LANDSCAPE_HEIGHT - BUTTOM_HEIGHT,
									  LANDSCAPE_WIDTH, 
									  BUTTOM_HEIGHT);
		UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"filterChooserBackground.png"]];
		bgImageView.frame = frameRect;
		bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:bgImageView];
		[bgImageView release];
		
		_filterTableView = [[EasyTableView alloc] initWithFrame:frameRect 
													numberOfColumns:[self.filters count]
															ofWidth:BUTTOM_WIDTH];
		_filterTableView.delegate = self;
		_filterTableView.tableView.allowsSelection = YES;
		_filterTableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_filterTableView.tableView.backgroundColor = [UIColor clearColor];

		
	}
	
	return _filterTableView;
}


/*
	滤镜列表呼出按钮
 */
- (UIButton *)filterButton{
	if (_filterButton) {
//		_filterButton = [UIButton alloc]ini
	}
	return _filterButton;
}

/*
	对单个的图片做滤镜处理
	@paramDic：
	为NSDictionary如下：
			index ---- 滤镜方法的索引号(NSNumber)
			image ---- 原始的图片(UIImage)
 */
- (void)filterSelector:(NSDictionary *)paramDic{
	@autoreleasepool {
		NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
		NSLog(@"thread start -------------- time = %f",time);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		if ([paramDic objectForKey:@"index"] && [paramDic objectForKey:@"image"]) {
			NSNumber *index = [paramDic objectForKey:@"index"];
			SEL selector = NSSelectorFromString([self.filters methodForIndex:index.intValue]);
			UIImage *imageLow = [paramDic objectForKey:@"image"];
			
			UIImage *imageFilterIcon = [imageLow performSelector:selector];
			if (_filterIconsDic) { //滤镜后的缩略图
				[_filterIconsDic setObject:imageFilterIcon forKey:index];
			}	
			if (_filterImagesDic) { //滤镜后的主图
				[_filterImagesDic setObject:imageFilterIcon forKey:index];
			}
		}

#pragma clang diagnostic pop
	}
}

/*
	从主图片生成缩略图
 */
- (void)prepareIcomForFilte:(UIImage *)image{
	
	NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
	NSLog(@"prepareIcomForFilte time = %f",time);

	if (!image) {
		return;
	}
	UIImage *imageLowOrigin = [[image copy] resizedImage:CGSizeMake(kImageAdjustMaxWidth, kImageAdjustMaxHeight) 
					   interpolationQuality:kCGInterpolationLow];
	
	NSMutableDictionary *filterIconsDic = [[NSMutableDictionary alloc]initWithCapacity:[self.filters count]];
	if (_filterIconsDic) {
		TT_RELEASE_SAFELY(_filterIconsDic);
	}
	_filterIconsDic = filterIconsDic;	

	NSMutableDictionary *filterImages = [[NSMutableDictionary alloc]initWithCapacity:[self.filters count]];
	if (_filterImagesDic) {
		TT_RELEASE_SAFELY(_filterImagesDic);
	}
	_filterImagesDic = filterImages;
	
	UIImage *imageLow = [imageLowOrigin copy];  // [[[UIImage alloc]initWithCGImage:imageLowOrigin.CGImage] autorelease];
	for (int i = 0 ; i < [self.filters count]; i ++) {
		//利用滤镜方法逐个生成缩略图
		//多线程
		NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
		NSNumber *index = [NSNumber numberWithInt:i];
		[paramDic setObject:index forKey:@"index"];
		[paramDic setObject:imageLow forKey:@"image"];
		
		[NSThread detachNewThreadSelector:@selector(filterSelector:) toTarget:self withObject:paramDic];
	}
	[imageLow release];

//	if ([NSThread isMainThread]) {
//		[NSThread sleepForTimeInterval:2];
//	}

	time = [[NSDate date]timeIntervalSince1970];
	NSLog(@"prepareIcomForFilte ending time = %f",time);
}


#pragma mark  EasyTableViewDelegate
- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect  {
    // view
	CGRect viewRect		= CGRectMake(0, 0, rect.size.width, rect.size.height);
    UIView * view = [[UIView alloc] initWithFrame:viewRect];
    
    // icon
	CGRect imageRect = CGRectMake((rect.size.width - ICON_SIZE) / 2, ICON_PADDING, ICON_SIZE, ICON_SIZE);
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:imageRect];
    imageView.tag = ICON_VIEW_TAG;
//	imageView.backgroundColor = [UIColor redColor];
	imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	imageView.layer.cornerRadius = 5.0;
	imageView.layer.masksToBounds = YES;
    [view addSubview:imageView];
    
    // label
    CGRect labelRect = CGRectMake(0, viewRect.size.height - 10, viewRect.size.width, 10);
    UILabel * labelView = [[UILabel alloc] initWithFrame:labelRect];
    labelView.textAlignment = UITextAlignmentCenter;
    labelView.textColor = [UIColor whiteColor];
    labelView.font = [UIFont boldSystemFontOfSize:10];
    labelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    labelView.tag = LABEL_VIEW_TAG;
    [view addSubview:labelView];
	
    // border
	CGRect r = imageRect;
	r = CGRectMake( r.origin.x - 8, r.origin.y - 8 , r.size.width + 16, r.size.height + 16); //变宽一点
    UIImageView *borderView		= [[UIImageView alloc] initWithFrame:r];
	borderView.tag				= BORDER_VIEW_TAG;
	borderView.contentMode = UIViewContentModeScaleAspectFill;
//	borderView.backgroundColor =[UIColor blueColor];
    [view addSubview:borderView];
    
    return view;
}

- (void)borderIsSelected:(BOOL)selected forView:(UIView *)view {
	UIImageView * borderView	= (UIImageView *)[view viewWithTag:BORDER_VIEW_TAG];
	if (selected) {
		NSString * borderImageName	=  @"filterChooserItemSelected.png" ;
		borderView.image			= [UIImage imageNamed:borderImageName];
	}else {
		borderView.image			= nil;
	}
	
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath {
    // label
    UILabel * label = (UILabel *)[view viewWithTag:LABEL_VIEW_TAG];
    label.text = [self.filters nameForIndex:indexPath.row];
    
    // icon
    UIImageView * imageView = (UIImageView *)[view viewWithTag:ICON_VIEW_TAG];
	if (_filterIconsDic/* && [_filterIcons count ] == [self.filters count]*/) {
		
		if (indexPath.row < [_filterIconsDic count]) {
			UIImage *imageIcon = [_filterIconsDic objectForKey:[NSNumber numberWithInt:indexPath.row]];
			NSLog(@"imageIcon %d",[imageIcon retainCount]);
			NSLog(@"Icon height = %f width = %f",imageIcon.size.height,imageIcon.size.width);
			imageView.image = imageIcon;
		}else {
			imageView.image = [UIImage imageNamed:[self.filters iconForIndex:indexPath.row]];
		}
		
	}else {
		imageView.image = [UIImage imageNamed:[self.filters iconForIndex:indexPath.row]];
	}
    
    // selectedIndexPath can be nil so we need to test for that condition
	BOOL isSelected = (easyTableView.selectedIndexPath) ? 
		([easyTableView.selectedIndexPath compare:indexPath] == NSOrderedSame) : NO;
	[self borderIsSelected:isSelected forView:view];
}

- (void) easyTableView:(EasyTableView *)easyTableView 
		  selectedView:(UIView *)selectedView
		   atIndexPath:(NSIndexPath *)indexPath
		deselectedView:(UIView *)deselectedView  
{
    // set border
    [self borderIsSelected:YES forView:selectedView];
    if (deselectedView) {
        [self borderIsSelected:NO forView:deselectedView];
    }
	
    // apply filter
	if (0 == indexPath.row) { //原照片
		self.filterImage = self.highQualityImage;
	}else{		
		if (_filterImagesDic && [_filterImagesDic objectForKey:[NSNumber numberWithInt:indexPath.row]]) {
			self.filterImage  = [_filterImagesDic objectForKey:[NSNumber numberWithInt:indexPath.row]];
		}
	}
}
/*
	设置滤镜图片，期间有翻页动画
 */
- (void)setFilterImage:(UIImage *)filterImage{
	TT_RELEASE_SAFELY(_filterImage);
	_filterImage = [filterImage retain];
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.currentImageView cache:YES];
	self.currentImageView.image = _filterImage;
    [UIView setAnimationDelegate:self];
    // 动画完毕后调用某个方法
//	[UIView setAnimationDidStopSelector:@selector(displayCurrentView)];
    [UIView commitAnimations];
}

#pragma mark - view lifecycle

- (void)loadView{
	[super loadView];
	
}

- (void)viewDidLoad{
	
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
	//缩放手势
	_pinchGesture = [[UIPinchGestureRecognizer alloc]   
					 initWithTarget:self action:@selector(scaleChange:)];  
    [_pinchGesture setDelegate:self];  
	
	//双击手势
    _doubleTapGesture = [[UITapGestureRecognizer alloc]
                         initWithTarget:self action:@selector(doubletapCurrentImage)];
    _doubleTapGesture.numberOfTapsRequired = 2;
    [_doubleTapGesture setDelegate:self];
	
	//单击手势
    _singleTapGesture = [[UITapGestureRecognizer alloc]
                         initWithTarget:self action:@selector(tapCurrentImage)];
    _singleTapGesture.numberOfTapsRequired = 1;
    [_singleTapGesture setDelegate:self];
	
	//选用高清图片
	//调用一次,切换成普通图片，同时隐藏图片大小标签
	isHDPhoto = NO;
	[self setSlibBarApearance];
	
}

- (void)viewWillAppear:(BOOL)animated{
	//在这里隐藏才是真正的隐藏,否则有延迟显示
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	
	[[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	[[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];

	[self displayCurrentView];//显示图片
	
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{

	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.filterTableView = nil;
	self.filterButton = nil;
	self.currentImageView  = nil;
	self.cutPhotoBgView = nil;
	self.highQualityImage = nil;
	self.normalQualityImage = nil;
	self.qualityLengthLabel = nil;
	
	self.topNavView = nil;
	
	self.slibBarPoiontView = nil;
	self.hdTextLabel = nil;
	self.normalTextLabel = nil;
	self.photoTurnLeftButton = nil;
	self.photoTurnRightButton = nil;
	self.toolBarView = nil;
	self.albumNameTableView = nil;
	self.albumSelectBarView = nil;
	self.albumNameLabel = nil;
	self.arrowView = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}
/*
	调整照片至中心位置
 */
- (void)ajustImageViewCenter{
    if(self.currentImageView){
        _currentImageView.frame = _lastDisplayFrame;
        if(_lastDisplayScale < 1.0){
            _lastDisplayScale = 1.0; //显示规模至1
            CGAffineTransform currentTransform = self.currentImageView.transform;  
            CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, 1.0, 1.0);  
            [self.currentImageView setTransform:newTransform];  
        }
    }
}
#pragma mark - 缩放图片手势
- (void) scaleChange:(UIPinchGestureRecognizer*)gestureRecognizer{
	return; //不支持缩放
	if (self.filterImage != self.highQualityImage) { //如果不是原图，不允许缩放
		return;
	}
	
	if([gestureRecognizer state] == UIGestureRecognizerStateEnded) {  
        _lastDisplayScale = 1.0;  
        if(_currentImageView.width < _lastDisplayFrame.size.width){
            _currentImageView.frame = _lastDisplayFrame;
        }
        [self touchesEnded:nil withEvent:nil];
        return;  
    }      
    CGFloat scale = 1.0 - (_lastDisplayScale - [(UIPinchGestureRecognizer*)gestureRecognizer scale]); 
	
    CGAffineTransform currentTransform = self.currentImageView.transform;  
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale); 
	
    if( _currentImageView.width > 3 *_lastDisplayFrame.size.width && scale > 1){ 
        return; //如果放大超过三倍，那么不再放大
    }
	
    if( _currentImageView.width <= _lastDisplayFrame.size.width * 1 && scale <= 1){
        CGAffineTransform currentTransform = self.currentImageView.transform;  
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, 1, 1);  
        [self.currentImageView setTransform:newTransform]; 
        _lastDisplayScale = 1; 
        return; 
    }
	
    [self.currentImageView setTransform:newTransform]; 
    _lastDisplayScale = [gestureRecognizer scale];  

}


/*
	显示相册列表
 */
- (void)showAlbumTable{
	[self.albumNameTableView reloadData];
	
	//旋转下拉箭头
	[UIView animateWithDuration:0.5 animations:^(){
		//旋转下拉箭头
		self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
		
		//下拉列表出现
		self.albumNameTableView.height = ALBUM_TABLE_HEIGHT;
	}];
	
	isExpand = !isExpand;
}

/* 
	隐藏相册列表
 */
- (void)hiddenAlbumTable{
	[UIView animateWithDuration:0.5 animations:^(){
		//下拉箭头归位
		self.arrowView.transform = CGAffineTransformIdentity;
		
		//收缩列表
		self.albumNameTableView.height = 0;
	}];
	
	isExpand = !isExpand; 
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	
    NSLog(@"cell.frame.size.height = %f",cell.frame.size.height);
    return cell.frame.size.height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return [self.albumIDArray count] + 1;//多一行照片添加相册
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (0 == indexPath.row) {//创建相册
		RNCreateAlbumViewController *rn = [[RNCreateAlbumViewController alloc]init];
		rn.delegate = self;
		[self.navigationController pushViewController:rn animated:YES];
		[rn release];
	}else if([self.albumIDArray count] > 0){ //普通相册名
		NSDictionary * dic = (NSDictionary * )[self.albumIDArray objectAtIndex:indexPath.row - 1];//获取相册名称
		self.albumID = [dic objectForKey: @"id"]; //相册ID
		self.albumNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"上传相册：%@", @"上传相册：%@") ,[dic objectForKey: @"title"]];
	}
	
	self.oldSelectedIndexPath = indexPath; //记录选中行
	[self hiddenAlbumTable]; //隐藏相册列表
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *cellIdentifier = @"albumcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	//设置Cell的字体
	UILabel *textLabel = [[[UILabel alloc]initWithFrame:CGRectMake(81, 16, 200, 22)]autorelease];
	textLabel.textAlignment = UITextAlignmentLeft;
	
	[textLabel setFont:[UIFont fontWithName:LIGHT_HEITI_FONT size:15]];
	[textLabel setTextColor:RGBCOLOR(255, 255, 255)];
	[textLabel setShadowColor:RGBACOLOR(0, 0, 0, 0.75)];
	[textLabel setShadowOffset:CGSizeMake(0, 2)];
	[textLabel setBackgroundColor:[UIColor clearColor]];
	if (0 == indexPath.row  ) {
		
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
										   reuseIdentifier:cellIdentifier] autorelease];
			
			
		} 
		
		UIImageView * addIconView = [[[UIImageView alloc]initWithImage:
									  [[RCResManager getInstance]imageForKey:@"album_add_icon"]]autorelease];
		addIconView.frame = CGRectMake(81, 16, addIconView.frame.size.width, addIconView.frame.size.height);
		//设置加号标记
		
		[cell.contentView removeAllSubviews];
		//缩进文本的位置
		textLabel.frame = CGRectOffset(textLabel.frame, 20 , 0);
		textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"添加新相册", @"添加新相册") ];
		[cell.contentView addSubview:textLabel];	
		[cell.contentView addSubview:addIconView];

	}else if(indexPath.row <= [self.albumIDArray count] ){
		
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:
					 UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
			
			
		} 
		[cell.contentView removeAllSubviews];
		[cell.contentView addSubview:textLabel];
		textLabel.text = [NSString stringWithFormat:@"%@",
						  [[_albumIDArray objectAtIndex:indexPath.row - 1] objectForKey:@"title"]];
		
		//如果是选中行的话 打钩钩
		if ([indexPath compare:self.oldSelectedIndexPath] == NSOrderedSame) { 
			UIImageView * addIconView = [[[UIImageView alloc]initWithImage:
										  [[RCResManager getInstance]imageForKey:@"hook_icon"]]autorelease];
			addIconView.frame = CGRectMake(81, 16, addIconView.image.size.width, addIconView.image.size.height);//设置加号标记
			
			cell.accessoryView = addIconView;
		}else {
			cell.accessoryView = nil;
		}
	}
	
	//设置Cell背景
	tableView.backgroundColor = [UIColor clearColor];
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	[cell setBackgroundColor:[UIColor clearColor]];
	UIImageView *backView = [[[UIImageView alloc]initWithImage:
							  [[RCResManager getInstance]imageForKey: @"album_table_cell"]]autorelease];
//	backView.alpha = 0.8; 
	[cell setBackgroundView:backView]; //设置Cell背景图
	
	UIImageView *backViewSel = [[[UIImageView alloc]initWithImage:
								 [[RCResManager getInstance]imageForKey:@"album_table_cell_hl"]]autorelease];
//	backViewSel.alpha = 0.2;
	[cell setSelectedBackgroundView:backViewSel]; //设置Cell选中的背景图片

	cell.height = backView.size.height;  //设置高度
	
    return cell;
}


#pragma mark - 网络请求相关
//网络请求成功
- (void)requestDidSucceed:(NSDictionary *)result {
    if (result) {
			[self.albumIDArray removeAllObjects];
            [self.albumIDArray addObjectsFromArray:[result objectForKey:@"album_list"]];
    }
	[self showAlbumTable];//展开下拉列表
	
}

//网络请求失败
- (void)requestDidError:(RCError *)error {
	UIAlertView *view = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"获取相册失败", @"获取相册失败")  delegate:nil
										cancelButtonTitle:NSLocalizedString(@"取消", @"取消")  otherButtonTitles: nil];
	[view show];
	[view release];
}

#pragma -mark RNCreateAlbumFinishDelegate
- (void)finishCreateAlbum{
	
	[self.albumIDArray removeAllObjects];//清空相册列表，以便重新加载
	[self tapAlbumSelectBar];//强制重载列表
}

#pragma  mark - 照片拖动
/*
	触摸开始
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  
{  
    UITouch *touch = [touches anyObject];  
    
    if ([touch view] == self.currentImageView) {   
        _gestureStartPoint=[touch locationInView: self.currentImageView];  
    }          
}  
/*
	触摸移动
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event  
{  
    UITouch *touch = [touches anyObject];    
    if ([touch view] == self.currentImageView)    
    {  
        CGPoint curr_point=[touch locationInView: self.currentImageView];  
        
        CGPoint imageCenter = self.currentImageView.center;  
        //直接改变中心坐标
        imageCenter.x += curr_point.x - _gestureStartPoint.x;  
        imageCenter.y += curr_point.y - _gestureStartPoint.y;  
        
//        self.currentImageView.center = imageCenter;
        //不支持移动
    }
}  

/* 
	返回图片经过越界调整之后的中心坐标
 */
- (CGPoint)adjustPhotoLocation{
	//显示的最小矩形框高度和宽度
	CGFloat minSize = MIN(_lastDisplayFrame.size.height, _lastDisplayFrame.size.width);
	
	CGRect cutFrame = CGRectMake(160 -  minSize / 2, 230 - minSize / 2 , minSize, minSize);
	CGFloat cutLeft = cutFrame.origin.x ;
	CGFloat cutRight = cutFrame.origin.x + cutFrame.size.width;
	CGFloat cutTop = cutFrame.origin.y;
	CGFloat cutButtom = cutFrame.origin.y + cutFrame.size.height;
	
	CGPoint imageCenter = self.currentImageView.center;//当前显示的图片中心，可能已经缩放过
	CGFloat returnX = imageCenter.x;
	CGFloat returnY = imageCenter.y;
	
	if (imageCenter.x + _currentImageView.size.width / 2 < cutRight ) {
		returnX = cutRight - _currentImageView.size.width / 2; //如果右边不越界
	}
	if (imageCenter.x - _currentImageView.size.width / 2 > cutLeft) {
		returnX = cutLeft + _currentImageView.size.width / 2;
	}
	
	if (imageCenter.y + _currentImageView.size.height / 2 < cutButtom) {
		returnY = cutButtom - _currentImageView.size.height / 2;
	}
	if (imageCenter.y - _currentImageView.size.height / 2 > cutTop) {
		returnY = cutTop + _currentImageView.size.height / 2;
	}
	NSLog(@"x= %f y= %f",returnX,returnY);
	
	return CGPointMake(returnX, returnY);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	[UIView animateWithDuration:0.3 animations:^(void){
		[self.currentImageView setCenter:[self adjustPhotoLocation]];//限制调整范围

	}];
} 

@end
