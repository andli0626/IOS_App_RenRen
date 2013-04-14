//
//  RNLoginViewController.h
//  RRPhotos
//
//  Created by yi chen on 12-3-27.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNBaseViewController.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RCClientLoginRequest.h"
@protocol RNLoginDelegate <NSObject>

//登陆结束
- (void)finishLogin;

@end

@interface RNLoginViewController : RNBaseViewController  <UITextFieldDelegate>{
	// 帐号输入框
	UITextField *emailField;
	
	// 密码输入框
	UITextField *passwordField;
    
    //注册按钮
    UIButton *registButton;
	
	//加载提示的view
	UIView *_activityIndicatorView;
	
	NSString* _lastUsername;
	
    NSString* _lastPassword;

	id<RNLoginDelegate> _loginDelegat;

}

/**
 * 产生正在登陆提示框
 */
- (UIView*)getActivityIndicatorView;

/**
 * 产生输入框
 */
+ (UITextField*)textInputFieldForCellWithValue:(NSString*)value secure:(BOOL)secure;

/**
 * 产生包含输入框的cell
 */
- (UIView*)containerCellWithTitle:(NSString*)title view:(UIView*)view;

/**
 * 登陆
 */
- (void)goAction;

/**
 * 注册
 */
- (void)registerAction;


/**
 * 
 */
- (void)handleMultiLogin;

@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UIButton *registButton;
@property (nonatomic, retain) UIView* activityIndicatorView;
@property (nonatomic, copy) NSString* lastUsername;
@property (nonatomic, copy) NSString* lastPassword;
@property(nonatomic,assign)id<RNLoginDelegate> loginDelegate;
@end

//画出登陆框的中间的线
@interface RNDrawLineView : UIView
{}

@end

