//
//  RCClientLoginRequest.h
//  RRSpring
//
//  Created by 黎 伟 ✪ on 4/14/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RCBaseRequest.h"

typedef void(^didLoginSuccess)();

@interface RCClientLoginRequest : RCBaseRequest{
    NSString *_account;
    NSString *_passwordMD5;
    didLoginSuccess _onLoginSuccess;
}

- (void)loginWithAccount:(NSString *)account
             passwordMD5:(NSString *)passwordMD5
                isVerify:(BOOL)isVerify
              verifyCode:(NSString *)verifyCode;

- (void)getClientInfo;

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *passwordMD5;
@property (nonatomic, copy) didLoginSuccess onLoginSuccess;

@end
