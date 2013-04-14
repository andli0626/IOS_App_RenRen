//
//  RNCreateAlbumViewController.h
//  RRSpring
//
//  Created by yi chen on 12-4-5.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNBaseViewController.h"
//新相册创建完成代理
@protocol RNCreateAlbumFinishDelegate <NSObject>

- (void)finishCreateAlbum;

@end


@interface RNCreateAlbumViewController : RNBaseViewController<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
	//顶部导航栏
	UIImageView *_topNavView;
	
	//主界面容器VIEW 用于控制输入框上下滑动
	UIView *_mainBackView;
	
	//取消按钮
	UIButton *_cancelButton;
	
	//确认按钮
	UIButton *_confirmButton;
	
	//相册名称
	UITextField *_albumNameField;
	
	
	//相册权限类型
	UITextField *_albumTypeField;
	
	//密码
	UITextField *_passwordField;
	
	//相册权限选择器
	UIPickerView *_pickTypeView;
	
	//工具栏
	UIToolbar *_toolBar;
	
	//相册权限类型
	NSArray *_typesArray;
	
	//相册权限选中的所以
	NSInteger albumTypeSelectedIndex;
	
	//新相册创建完成回调
	id<RNCreateAlbumFinishDelegate> _delegate;
	
	//网络请求
//	RCGeneralRequestAssistant *_requestAssistant;
}

@property(nonatomic,retain)UIImageView *topNavView;

@property(nonatomic,retain)UIView *mainBackView;

@property(nonatomic,retain)UIButton *cancelButton;

@property(nonatomic,retain)UIButton *confirmButton;

@property(nonatomic,retain)UITextField *albumNameField;

@property(nonatomic,retain)UIPickerView *pickTypeView;

@property(nonatomic,retain)UIToolbar *toolBar;

@property(nonatomic,retain)NSArray *typesArray;

@property(nonatomic,retain)UITextField *albumTypeField;

@property(nonatomic,retain)UITextField *passwordField;

@property(nonatomic,assign)id<RNCreateAlbumFinishDelegate> delegate;

@property(nonatomic,retain)RCGeneralRequestAssistant *requestAssistant;
@end
