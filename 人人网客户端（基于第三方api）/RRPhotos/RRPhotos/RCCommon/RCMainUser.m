//
//  RCMainUser.m
//  RRSpring
//
//  Created by yusheng.wu on 12-2-20.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import "RCMainUser.h"

// 最后一次登录的用户ID
#define kLastLoginUserId            @"kLastLoginUserId"
// 5.0之前版本持久化 MainUser 的 Key
#define kLoginUserKeyLowerV5              @"kRRUserKey" 


// mainUser持久化文件名
#define kMainUserFileName @"user"
// 公共目录名
#define kCommonDir @"common"

@interface RCMainUser (Private)

//  是否需要从5.0之前版本更新
+ (BOOL)isNeedUpdateLowerV5:(NSNumber *)userId;

// 从5.0之前版本更新
+ (RCMainUser *)readFromDiskLowerV5:(NSNumber *)userId;

// 从持久化数据中读取mainUser
+ (RCMainUser *)readFromDisk:(NSNumber *)userId;

// 清除 5.0 之前的缓存
+ (void)clearLowerV5Cache:(NSNumber *)userId;

// 5.0 之前的mainuser持久化路径
+ (NSString *)persistPathLowerV5:(NSNumber *)userId;

// 5.0 版本之后的持久化路径
- (NSString *)persistPath:(NSNumber *)userId;



@end

static RCMainUser* _instance = nil;

@implementation RCMainUser

@synthesize loginAccount = _loginAccount;
@synthesize ticket = _ticket;
@synthesize sessionKey = _sessionKey;
@synthesize userSecretKey = _userSecretKey;
@synthesize md5Password = _md5Password;
@synthesize loginStatus = _loginStatus;
@synthesize lastLoginDate = _lastLoginDate;
@synthesize checkIsNewUser = _checkIsNewUser;
@synthesize sessionId = _sessionId;
@synthesize isLogin = _isLogin;
@synthesize loginCount = _loginCount;

+ (RCMainUser *) getInstance {
	@synchronized(self) {
		if (_instance == nil) {
            // 看是否有最近的登录用户Id
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSNumber *userId = [defaults objectForKey:kLastLoginUserId];
            
            if (userId) {
                // 登陆过的逻辑
                if ([RCMainUser isNeedUpdateLowerV5:userId]) {
                    // 需要从5.0之前版本升级
                    _instance = [RCMainUser readFromDiskLowerV5:userId];
                    [RCMainUser clearLowerV5Cache:userId];
                    [_instance persist];
                }
                else {
                    // 5.0 之后版本逻辑
                    _instance = [RCMainUser readFromDisk:userId];
                    if (!_instance) {
                        [[RCMainUser alloc] init]; // assignment not done here
                    }
                }
            } else {
                // 从未登陆过的逻辑
                [[RCMainUser alloc] init];
            }
		}
	}
    
	return _instance;
}


+ (id) allocWithZone:(NSZone*) zone {
	@synchronized(self) {
		if (_instance == nil) {
			_instance = [super allocWithZone:zone];  // assignment and return on first allocation
			return _instance;
		}
	}
	return nil;
}

- (id) copyWithZone:(NSZone*) zone {
	return _instance;
}

- (id) retain {
	return _instance;
}

- (unsigned) retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void) release {
	// do nothing
}

- (id) autorelease {
	return self;
}

- (id) init
{
	if (self = [super init]){
        [self clear];
        self.userId = [NSNumber numberWithInt:0];
	}
	return self;
}


- (void) dealloc
{
    self.loginAccount = nil;
    self.md5Password = nil;
    self.ticket = nil;
    self.sessionKey = nil;
    self.userSecretKey = nil;
    self.sessionId = nil;
	
	[super dealloc];
}



- (void) clear
{
	self.ticket = nil;
	self.sessionKey = nil;
	self.userSecretKey = nil;
	self.md5Password = nil;
	self.lastLoginDate = 0.0;
    self.userName = nil;
    self.networkName = nil;
    self.tinyurl = nil;
    self.headurl = nil;
    self.checkIsNewUser = NO;
    self.sessionId = nil;
}

#pragma mark -
#pragma mark Public
- (void)persist {
    NSNumber *userId = self.userId;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:userId forKey:kLastLoginUserId];
	
	if (userId) {
        NSString *persistPath = [RCMainUser persistPath:userId];
        [NSKeyedArchiver archiveRootObject:self toFile:persistPath];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)logout {
	RCMainUser *mainUser = _instance;
    mainUser.isLogin = NO;
	[mainUser clear];
	[mainUser persist];
}

- (BOOL) isMainUser
{
	return YES;
}


- (BOOL)isMainUserId:(NSNumber*)anUserId {
	// 在没有id的情况的, 将默认是mainuser
	if (!anUserId) {
		return TRUE;
	}
	
	if (!self.userId) {
		return FALSE;
	}
	
	return NSOrderedSame == [self.userId compare:anUserId] ? TRUE : FALSE;
}

#pragma mark -
#pragma mark push notification methods
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)registerPushNotification{
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeNone|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
}

#pragma mark -
#pragma mark NSCoding methods
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
        // 由于兼容 5.0 之前版本，所以key值与属性名不一致
		self.ticket = [decoder decodeObjectForKey:@"mticket"];
		self.sessionKey = [decoder decodeObjectForKey:@"msessionKey"];
		self.userSecretKey = [decoder decodeObjectForKey:@"mprivateSecretKey"];
		self.loginAccount = [decoder decodeObjectForKey:@"loginAccount"];
		self.md5Password = [decoder decodeObjectForKey:@"md5Password"];
        self.checkIsNewUser = [decoder decodeBoolForKey:@"checkIsNewUser"];
	}
	return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
	[super encodeWithCoder:encoder];
    
	[encoder encodeObject:self.loginAccount forKey:@"loginAccount"];
	[encoder encodeObject:self.md5Password forKey:@"md5Password"];
	[encoder encodeObject:self.ticket forKey:@"mticket"];
	[encoder encodeObject:self.sessionKey forKey:@"msessionKey"];
	[encoder encodeObject:self.userSecretKey forKey:@"mprivateSecretKey"];
    [encoder encodeBool:self.checkIsNewUser forKey:@"checkIsNewUser"];
}

//  是否需要从5.0之前版本更新
+ (BOOL)isNeedUpdateLowerV5:(NSNumber *)userId{
    NSString *userFile = [RCMainUser persistPathLowerV5:userId];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:userFile]) {
        return YES;
    }
    return NO;
}

// 从5.0之前版本更新
+ (RCMainUser *)readFromDiskLowerV5:(NSNumber *)userId{
    NSString *userFile = [RCMainUser persistPathLowerV5:userId];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:userFile];
}

// 从持久化数据中读取mainUser
+ (RCMainUser *)readFromDisk:(NSNumber *)userId{
    NSString *userFile = [RCMainUser persistPath:userId];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:userFile];
}

// 清除 5.0 之前的缓存
+ (void)clearLowerV5Cache:(NSNumber *)userId{
    NSString *userFile = [RCMainUser persistPathLowerV5:userId];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:userFile error:nil];
}

- (BOOL) checkLoginInfo
{
	if (self.sessionKey && self.userSecretKey) {
		return YES;
	}
	
	return NO;
}

// App Document 路径
+ (NSString *)documentPath{
    NSArray *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [searchPath objectAtIndex:0];
    return path;
}

// 公共文件夹路径
+ (NSString *)commonPath{
    NSString *path = [[RCMainUser documentPath] stringByAppendingPathComponent:kCommonDir];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileMgr createDirectoryAtPath:path
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
        if (error) {
            NSLog(@"创建 commonPath 失败 %@", error);
        }
    }
    
    return path;
}

// 用户路径
- (NSString *)userDocumentPath{
    NSString *path = [[RCMainUser documentPath] stringByAppendingPathComponent:[self.userId stringValue]];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileMgr createDirectoryAtPath:path
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
        if (error) {
            NSLog(@"创建 userDocumentPath 失败 %@", error);
        }
    }
    
    return path;
}

// 5.0 之前的mainuser持久化路径
+ (NSString *)persistPathLowerV5:(NSNumber *)userId{
	NSString *documentDirectory = [RCMainUser documentPath];
	NSString *fileName = [NSString stringWithFormat:@"rr_persistence_%@_object_%@", userId, kLoginUserKeyLowerV5];
	NSString* path = [documentDirectory stringByAppendingPathComponent:fileName];
	return path;
}

// 5.0 版本之后的持久化路径
+ (NSString *)persistPath:(NSNumber *)userId{
    NSString *dirPath = [[RCMainUser documentPath] stringByAppendingPathComponent:[userId stringValue]];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:dirPath]) {
        NSError *error = nil;
        [fileMgr createDirectoryAtPath:dirPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
        if (error) {
            NSLog(@"创建 userDocumentPath 失败 %@", error);
        }
    }
    
    NSString *path = [dirPath stringByAppendingPathComponent:kMainUserFileName];
    return path;
}

@end
