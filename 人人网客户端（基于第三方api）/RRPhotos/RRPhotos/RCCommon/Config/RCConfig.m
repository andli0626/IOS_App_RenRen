//
//  RCConfig.m
//  RenrenCore
//
//  Created by Sun Cloud on 6/1/11.
//  Copyright 2011 www.renren.com. All rights reserved.
//

#import "RCConfig.h"
#import "UIDevice+UIDeviceExt.h"
#import "NSString+NSStringEx.h"
#import "SBJsonWriter.h"

static RCConfig *_globalConfig = nil;

@implementation RCConfig

@synthesize appStoreId = _appStoreId;
@synthesize appBundleID = _appBundleID;
@synthesize appId = _appId;
@synthesize fromID = _fromID;
@synthesize apiUrl = _apiUrl;
@synthesize apiKey = _apiKey;
@synthesize appSecretKey = _appSecretKey;
@synthesize clientName = _clientName;
@synthesize version = _version;
@synthesize deviceModel = _deviceModel;
@synthesize clientInfo = _clientInfo;
@synthesize chatHostUrl = _chatHostUrl;
@synthesize chatServerVersion = _chatServerVersion;
@synthesize talkServerAddr = _talkServerAddr; 
@synthesize talkServerPort = _talkServerPort;
@synthesize findPeopleUrl = _findPeopleUrl;
@synthesize registerUrl = _registerUrl;
@synthesize findPasswordUrl = _findPasswordUrl;
@synthesize helpUrl = _helpUrl;

- (void)dealloc
{
    self.appStoreId = nil;
    self.appBundleID = nil;
    self.appId = nil;
    self.fromID = nil;
    self.apiUrl = nil;
    self.apiKey = nil;
    self.appSecretKey = nil;
    self.clientName = nil;
    self.version = nil;
    self.deviceModel = nil;
    self.clientInfo = nil;
    self.chatHostUrl = nil;
    self.chatServerVersion = nil;
    self.talkServerAddr = nil; 
    self.findPeopleUrl = nil;
    self.registerUrl = nil;
    self.findPasswordUrl = nil;
    self.helpUrl = nil;
    
    [super dealloc]; 
}

- (id)init {
    self = [super init]; 
    if (self) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        UIDevice *device = [UIDevice currentDevice];
        UIScreen *screen = [UIScreen mainScreen];
        //应用App Store的ID（AppleID）
        self.appStoreId = @"316709252";
    
        // 应用App Store的Bundle ID
        self.appBundleID = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
        
        // 应用App ID (服务分配)
        self.appId = @"185292";
        //self.appId = @"169485";
        
        //注册url
        self.registerUrl = @"http://client2.test.renren.com/register";
        //帮助中心
        self.helpUrl = @"http://3g.renren.com/help/guestbook.do?";
        
        //找回密码
        self.findPasswordUrl = @"http://client2.test.renren.com/reset_password";

        // 客户端 FromID（服务分配）
        self.fromID = @"9100301";
        // self.fromID = @"2000505";
        
        // API 地址（服务分配）

        self.apiUrl = @"http://mc3.test.renren.com/api";//开发服务器
//		self.apiUrl = @"http://mc1.test.renren.com/api";//开发服务器

        //self.apiUrl = @"http://mc3.test.renren.com/api";//开发服务器
self.apiUrl = @"http://api.m.renren.com/api";//正式服务器
        
        // API Key（服务分配）
        self.apiKey = @"980aca4002b744f1bf37df8ee28e2c92";
        
        // App Secret Key（服务分配）
        self.appSecretKey = @"1610a966b2fe4270866aeb78f34de191";
        
        // 客户端名称
        self.clientName = @"xiaonei_iphone";
        
        // 客户端版本
        self.version = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
        
        // 设备型号
        self.deviceModel = [UIDevice machineModelName];
        
        // 客户端信息（client_info）
        CGSize screenSize = screen.bounds.size;
        NSString *otherStr = @"";
        NSString *carrierCode = [UIDevice carrierCode];
        if (carrierCode) {
            otherStr = [otherStr stringByAppendingString:carrierCode];
        }
        otherStr = [otherStr stringByAppendingString:@","];
        
        NSDictionary *clientInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.deviceModel, @"model",
                                    [UIDevice macAddress], @"mac",
                                    [NSString stringWithFormat:@"%@%@", device.systemName, device.systemVersion], @"os" , 
                                    [NSString stringWithFormat:@"%.0fX%.0f", screenSize.width, screenSize.height], @"screen",
                                    self.fromID, @"from",
                                    self.version, @"version",
                                    otherStr, @"other",
                                    nil];
        SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        self.clientInfo = [jsonWriter stringWithObject:clientInfo];
        [jsonWriter release];
        
        ///////////////////////////////////////////////////////////////////////////////////////////
        // 线上聊天服务
        //self.chatServerVersion = @"talk.m.renren.com";
        //self.chatServerVersion = @"talk.apis.tk";
        // 聊天服务器版本
        self.chatServerVersion = @"5";
        //self.chatServerVersion = @"8";
        //self.talkServerAddr = @"10.3.18.204";
        self.talkServerAddr = @"talk.apis.tk";
        self.talkServerPort = 25553;
        
        // 搜索好友地址
        self.findPeopleUrl = @"http://mt.renren.com/client/search";
    }
    return self;
}

- (NSString *)udid{
    return [UIDevice macAddress];
}

// API 统计信息
+ (NSString *)miscWithHtf:(int)htfCode{
    NSString *misc = @"";
    Reachability *reachability = [Reachability reachabilityWithHostname:[RCConfig globalConfig].apiUrl];
    misc = [misc stringByAppendingFormat:@"%d", htfCode];
    misc = [misc stringByAppendingString:@","];
    misc = [misc stringByAppendingString:[reachability isReachable]?@"0":@"1"];
    misc = [misc stringByAppendingString:[reachability isReachableViaWiFi]?@"1":@"0"];
    return misc;
}

+ (RCConfig* )globalConfig {
    if(!_globalConfig) {
        _globalConfig = [[RCConfig alloc] init];
    }
    
    return _globalConfig;
}

+ (void)setGlobalConfig:(RCConfig *)config {
    if (_globalConfig != config) {
        [_globalConfig release];
        _globalConfig = [config retain];
    }
}
@end
