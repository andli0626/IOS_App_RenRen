//
//  RCConfig.h
//  RenrenCore
//
//  Created by Sun Cloud on 6/1/11.
//  Copyright 2011 www.renren.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// htf 统计代码
typedef enum _HTFCode{
    kHTFXXX = 10002,
}HTFCode;


@interface RCConfig : NSObject  {
    //应用App Store的ID（AppleID）
    NSString *_appStoreId;
    // 应用App Store的Bundle ID
    NSString *_appBundleID;
    // 应用App ID (服务分配)
    NSString *_appId;
    // 客户端 FromID（服务分配）
    NSString *_fromID;
    // API 地址（服务分配）
    NSString *_apiUrl;
    // API Key（服务分配）
    NSString *_apiKey;
    // App Secret Key（服务分配）
    NSString *_appSecretKey;
    // 客户端名称
    NSString *_clientName;
    // 客户端版本
    NSString *_version;
    // 设备型号
    NSString *_deviceModel;
    // 客户端信息（client_info）
    NSString *_clientInfo;
    // 聊天服务器相关（消息长连接）
    NSString* _chatHostUrl;
    NSString *_chatServerVersion;
    NSString *_talkServerAddr;
    UInt16 _talkServerPort;
    //搜索好友地址
    NSString *_findPeopleUrl;
    //注册
    NSString *_registerUrl;
    //找回密码
    NSString *_findPasswordUrl;
    //帮助中心
    NSString *_helpUrl;
}

+ (RCConfig* )globalConfig;
+ (void)setGlobalConfig:(RCConfig *)config;

// udid 取设备 MAC(兼容)
- (NSString *)udid;

// API 统计信息
+ (NSString *)miscWithHtf:(int)htfCode;

//应用App Store的ID（AppleID）
@property (nonatomic, copy) NSString *appStoreId;
// 应用App Store的Bundle ID
@property (nonatomic, copy) NSString *appBundleID;
// 应用App ID (服务分配)
@property (nonatomic, copy) NSString *appId;
// 客户端 FromID（服务分配）
@property (nonatomic, copy) NSString *fromID;
// API 地址（服务分配）
@property (nonatomic, copy) NSString *apiUrl;
// API Key（服务分配）
@property (nonatomic, copy) NSString *apiKey;
// App Secret Key（服务分配）
@property (nonatomic, copy) NSString *appSecretKey;
// 客户端名称
@property (nonatomic, copy) NSString *clientName;
// 客户端版本
@property (nonatomic, copy) NSString *version;
// 设备型号
@property (nonatomic, copy) NSString *deviceModel;
// 客户端信息（client_info）
@property (nonatomic, copy) NSString *clientInfo;
// 聊天服务器相关（消息长连接）
@property (nonatomic, copy) NSString *chatHostUrl;
@property (nonatomic, copy) NSString *chatServerVersion;
@property (nonatomic, copy) NSString *talkServerAddr;
@property (nonatomic, assign) UInt16 talkServerPort;
//搜索好友地址
@property (nonatomic, copy) NSString *findPeopleUrl;
//注册
@property (nonatomic, copy) NSString *registerUrl;
//找回密码
@property (nonatomic, copy) NSString *findPasswordUrl;
//帮助中心
@property (nonatomic, copy) NSString *helpUrl;

@end
