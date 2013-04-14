//
//  RNPickPhotoHelper.h
//  RRSpring
//
//  Created by yi chen on 12-3-31.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNEditPhotoViewController.h"

//相册拾取完成回调（已编辑）
//photoInfo 包括拍照的原始附加信息 key ：UIImagePickerControllerMediaMetadata
//photoInfo 包括照片要上传的到哪个的相册名称 关键字为: @"id"
@protocol RNPickPhotoDelegate <NSObject>

- (void)pickPhotoFinished:(UIImage *)imagePicked photoInfoDic: (NSDictionary * )photoInfoDic;

@end

@interface RNPickPhotoHelper : NSObject<UINavigationControllerDelegate, 
					UIImagePickerControllerDelegate ,RNEditPhotoFinishDelegate>
{
	//照片拾取控制器
	UIImagePickerController *_imagePickerController;
	
	//编辑照片页面
	RNEditPhotoViewController *_editPhotoController;

	//照片来源
	UIImagePickerControllerSourceType _sourceType;
	
	//返回的照片数据
	UIImage *_imageToReturn;
	
	//返回的照片附加信息，如照片要上传到的相册名称（关键字@“album_name”） id待加入
	NSDictionary * _photoInfoDic;
	
	id <RNPickPhotoDelegate> _delegate;
	
	//传进来的父类viewcontroller,如果有传直接用于弹出UIImagePickerController,如果没传,则用AppDelegate
	UIViewController *_parentViewController;
}

@property(nonatomic,retain)UIImagePickerController *imagePickerController;

@property(nonatomic,retain)RNEditPhotoViewController *editPhotoController;

@property(nonatomic,assign)UIImagePickerControllerSourceType sourceType;

@property(nonatomic,retain)UIImage *imageToReturn;

@property(nonatomic,retain)NSDictionary *photoInfoDic;

@property(nonatomic,assign)id<RNPickPhotoDelegate> delegate;

@property(nonatomic,assign)UIViewController *parentViewContrller;

/**
 * 获取照片，数据通过回调传回
 */
- (void)pickPhotoWithSoureType:(UIImagePickerControllerSourceType) sourceType;

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
