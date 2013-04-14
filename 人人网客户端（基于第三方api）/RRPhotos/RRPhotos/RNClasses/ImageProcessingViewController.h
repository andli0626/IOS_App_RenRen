//
//  ImageProcessingViewController.h
//  ImageProcessing
//
//  Created by yi chen on 12-3-27.
//  Copyright (c) 2012年 renren. All rights reserved.
//
#import "RNPickPhotoHelper.h"

@protocol ProcessingImageViewDelegate;

//touch image delegate
@interface ProcessingImageView : UIImageView
{
	id <ProcessingImageViewDelegate> delegate;
}
@property (assign) id <ProcessingImageViewDelegate> delegate;

@end

@protocol ProcessingImageViewDelegate
-(void)tapOnCallback:(ProcessingImageView*)imageView;
@end

//-----------------------------
@interface ImageProcessingViewController : UIViewController <UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,ProcessingImageViewDelegate>
{	
	//开始选择照片，或者拍照
	UIBarButtonItem *startItem;
	
	//保存照片
	UIBarButtonItem *saveItem;
	
	//照片操作工具栏
	UIToolbar *toolbar;
	
	//导航
	UINavigationBar *navBar;
	
	//照片获取界面
	UIImagePickerController *imagePickerController;
	
	//分区控制
	UISegmentedControl *segc;

	//用于存储操作的照片
	ProcessingImageView *imageV;
	
	//当前照片
	UIImage *currentImage;
	
	//是否显示工具栏
	BOOL show;
	
	RNPickPhotoHelper *_pickPhotoHelper;
}
@property (retain)  UIBarButtonItem *startItem;
@property (retain)  UIBarButtonItem *saveItem;
@property (retain)  UISegmentedControl *segc;
@property (retain)  UIImageView *imageV;
@property (retain)  UIToolbar *toolbar;
@property (retain)  UINavigationBar *navBar;
@property (retain) UIImage *currentImage;
@property (nonatomic, retain) RNPickPhotoHelper *pickPhotoHelper;
-(void)begin:(id)sender;
-(void)effectChange:(id)sender;
-(void)save:(id)sender;
@end
