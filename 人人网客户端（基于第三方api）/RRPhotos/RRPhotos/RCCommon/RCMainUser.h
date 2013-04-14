//
//  RCMainUser.h
//  RRSpring
//
//  Created by yusheng.wu  on 12-2-20.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCUser.h"

//2012-03-29 add by lyfing.
typedef enum
{
    RRLoginStatusDomeamLogined,     //表示已经通过后台自动方式登录
    RRLoginStatusLogined,          //表示已经通过输入用户名密码登录
}RRLoginStatus;

@interface RCMainUser : RCUser <NSCoding> {
	// 登录时填写的登录帐号。
	NSString* _loginAccount;
    
    // 经过md5加密的password。
	NSString* _md5Password;
	
    // 3G手机开放平台的ticket。登录3G手机开放平台成功后获得。
	NSString* _ticket;

    // 3G手机开放平台的session key。登录3G手机开放平台成功后获得。
	NSString* _sessionKey;

    // 3G手机开放平台的private secret key。登录3G手机开放平台成功后获得。
	NSString* _userSecretKey;
    
    // 最后一次登陆时间，登录3G手机开放平台成功后获得。（now）
	double _lastLoginDate;
    
    // 用户登陆次数
    NSUInteger _loginCount;
	
	// 表示当前登录用户的状态。
    RRLoginStatus _loginStatus;
	
    // 是否是新注册用户 (fill_stage)
    BOOL _checkIsNewUser;
    
    // 是否已登陆
    BOOL _isLogin;
    
    // 聊天时所需要的会话ID,登录后可以取得
    NSString *_sessionId;
}
/**
 * 表示当前登录用户的状态。
 */
@property RRLoginStatus loginStatus;

/**
 * 表示登录时填写的登录帐号。
 */
@property (nonatomic, copy) NSString* loginAccount;

/*
 * 经过md5加密的password
 */
@property (nonatomic, copy) NSString* md5Password;

/**
 * 表示3G手机开放平台的ticket。登录3G手机开放平台成功后获得。
 */
@property (nonatomic, copy) NSString* ticket;

/**
 * 表示3G手机开放平台的session key。登录3G手机开放平台成功后获得。
 */
@property (nonatomic, copy) NSString* sessionKey;

/**
 * 表示3G手机开放平台的private secret key。登录3G手机开放平台成功后获得。
 */
@property (nonatomic, copy) NSString* userSecretKey;

/*
 * 用户登陆次数
 */
@property (nonatomic, assign) NSUInteger loginCount;

/*
 * 是否已登陆
 */
@property (nonatomic, assign) BOOL isLogin;

/*
 * 最后一次登陆时间，登录3G手机开放平台成功后获得。（now）
 */
@property (nonatomic, assign) double lastLoginDate;

/*
 * 是否是新注册用户 (fill_stage)
 */
@property (nonatomic, assign) BOOL checkIsNewUser;

/*
 * 聊天时所需要的会话ID,登录后可以取得
 */
@property (nonatomic, copy) NSString *sessionId;

#pragma mark -
#pragma mark Public

/**
 * 创建一个Main User对象.
 * 首先从持久化层.初始化,如果没有的话,那么直接生成新的对象.
 */
+ (RCMainUser*)getInstance;

/**
 * 持久化存档。
 */
- (void)persist;

/**
 * 登出动作，仅修改了MainUser的状态和数值。
 */
- (void)logout;

/**
 * 清空MainUser对象数据。一般在切换登录用户时，或者登出时使用。
 */
- (void) clear;

/**
 * 判断是否为登录用户的id.
 * 
 * @param userId 被判断的用户id
 * @return 如果是登录用户,返回TRUE,否则返回FALSE.
 */
- (BOOL)isMainUserId:(NSNumber*)userId;

/*
 * 是否包含了登陆信息，若包含可进行自动登陆
 */
- (BOOL) checkLoginInfo;

// 注册远程push
+ (void)registerPushNotification;

// 一些相关目录

// App Document 路径
+ (NSString *)documentPath;

// 公共文件夹路径
+ (NSString *)commonPath;

// 用户路径
- (NSString *)userDocumentPath;


@end

