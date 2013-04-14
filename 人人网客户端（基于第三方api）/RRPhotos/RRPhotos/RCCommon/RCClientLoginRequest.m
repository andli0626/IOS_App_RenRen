//
//  RCClientLoginRequest.m
//  RRSpring
//
//  Created by 黎 伟 ✪ on 4/14/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RCClientLoginRequest.h"
#import "RCMainUser.h"
#import "UIDevice+UIDeviceExt.h"
//#import "HummerSettings.h"

@implementation RCClientLoginRequest

@synthesize account = _account;
@synthesize passwordMD5 = _passwordMD5;
@synthesize onLoginSuccess = _onLoginSuccess;

- (void)dealloc{
    self.account = nil;
    self.passwordMD5 = nil;
    self.onLoginSuccess = nil;
    
    [super dealloc];
}

- (id)init{
    self = [super init];
    if (self) {
        self.onCompletion = ^(id result){
            NSDictionary *resultInfo = (NSDictionary *)result;
            NSString *sessionKey = [resultInfo objectForKey:@"session_key"];
            NSString *ticket = [resultInfo objectForKey:@"ticket"];
            NSNumber *uid = [resultInfo objectForKey:@"uid"];
            NSString *secretKey = [resultInfo objectForKey:@"secret_key"];
            NSString *userName = [resultInfo objectForKey:@"user_name"];
            NSString *headUrl = [resultInfo objectForKey:@"head_url"];
            NSNumber *now = [resultInfo objectForKey:@"now"];
            NSString *loginCount = [resultInfo objectForKey:@"login_count"];
            NSString *fillStage = [resultInfo objectForKey:@"fill_stage"];
            
            RCMainUser *mainUser = [RCMainUser getInstance];
            mainUser.loginAccount = self.account;
            mainUser.md5Password = self.passwordMD5;
            mainUser.sessionKey = sessionKey;
            mainUser.ticket = ticket;
            mainUser.userId = uid;
            mainUser.userSecretKey = secretKey;
            mainUser.userName = userName;
            mainUser.headurl = headUrl;
            mainUser.lastLoginDate = [now doubleValue];
            mainUser.checkIsNewUser = [fillStage boolValue];
            mainUser.loginCount = [loginCount integerValue];
            mainUser.isLogin = YES;
            [mainUser persist];
//            if(ticket){
//                NSMutableDictionary *addQuery=[HummerSettings shareInstance].additionalQuery;
//                [addQuery setObject:ticket forKey:@"sid"];
//            }
            
            if (self.onLoginSuccess) {
                self.onLoginSuccess();
            }
        };
        
        self.onError = ^(RCError* error){
            NSLog(@"登陆失败！");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"错误", @"错误")
                                                            message:[error titleForError]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"确定", @"确定")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        };
    }
    
    return self;
}

- (void)loginWithAccount:(NSString *)account
             passwordMD5:(NSString *)passwordMD5
                isVerify:(BOOL)isVerify
              verifyCode:(NSString *)verifyCode{
    if (account == nil || passwordMD5 == nil) {
        return;
    }
    
    self.account = account;
    self.passwordMD5 = passwordMD5;
    
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:10];
    [query setObject:self.account forKey:@"user"];
    [query setObject:self.passwordMD5 forKey:@"password"];
    [query setObject:[UIDevice macAddress] forKey:@"uniq_id"];
    [query setObject:isVerify ? @"1" : @"0"
              forKey:@"isverify"];
    if (verifyCode && [verifyCode length] > 0) {
        [query setObject:verifyCode forKey:@"verifycode"];
    }
    self.secretKey = [RCConfig globalConfig].appSecretKey;
	//发送请求
	[self sendQuery:query withMethod:@"client/login"];
}

- (void)getClientInfo{
    RCMainUser *mainUser = [RCMainUser getInstance];
    self.account = mainUser.loginAccount;
    self.passwordMD5 = mainUser.md5Password;
    
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:10];
    [query setObject:mainUser.sessionKey forKey:@"session_key"];
    [self sendQuery:query withMethod:@"client/getLoginInfo"];
}

@end
