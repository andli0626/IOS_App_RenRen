//
//  RCUser.h
//  RRSpring
//
//  Created by yusheng.wu on 12-2-20.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 后台接口类型定义。
 */
typedef enum {
	RRApiRR3G				= 0,  // 新接口：人人3G
	RRApiRROpenPlatform		= 1 // 默认值：人人开放平台
} RRApiType;

@interface RCUser : NSObject<NSCoding>
{
	// 表示用户的唯一ID。
	NSNumber* _userId;
	
	// 新加的user属性，用于可以通过拼音搜索好友
	NSString* pinyinName;
	
	
	NSString* networkName;
	
	// 表示小的用户头像.50*50px
	NSString* _tinyurl;
	
	// 表示中等大小的用户头像.100*100px
	NSString* _headurl;
	
	// 表示中等大小的用户头像.200*200px
	NSString* _mainurl;
	
	// 表示用户的名字.
	NSString* userName;
	
	NSInteger online;
	
	// (dirty == NO) means this user is identical to the record in database.
	BOOL dirty;
	
	// 当取Profile后取得最准确的名字,这个时候锁定名字,不让其他地方在更新名字.
	BOOL _lockName;
	
    NSString* usererror;
	
	BOOL isChecked;
    
    RRApiType _apiType;
}

/**
 * 取得性别名称
 */
- (NSString*)sexName;

/**
 * 取得个人描述文本.
 */
//- (TTStyledText*)profileText;

/**
 * 通过用户id初始化.
 */
- (id) initWithUserId:(NSNumber*)userId;

/**
 * 根据接口(batch.run)返回的批处理信息填充完整用户信息.
 *
 * @param info 用户信息数组.
 */
- (void)fillWithArrayForBatchRun:(NSArray*)info;

/**
 * 根据接口(profile.getInfo)返回的用户信息字典数据填充完整用户信息.
 * 目前主要取当前状态和网络名称
 *
 * @param dictionary 用户信息字典.
 */
- (void) fillWithDictionaryForProfileGetInfo:(NSDictionary*)dictionary;

/**
 * 根据接口(phoneclient.getProfile)返回的用户信息字典数据填充完整用户信息.
 *
 * @param dictionary 用户信息字典.
 */
- (void) fillWithDictionaryForGetProfile:(NSDictionary*)dictionary;

/**
 * 根据接口(users.getInfo)返回的用户信息字典数据填充完整用户信息.
 *
 * @param dictionary 用户信息字典.
 */
- (void) fillWithDictionaryForUsersGetInfo:(NSDictionary*)dictionary;

- (void) didReceiveMemoryWarning;

/**
 * 判断是否是登录用户.
 */
- (BOOL) isMainUser;

/**
 * 通过id判断是否是page
 */
+ (BOOL)isPageUser:(NSNumber*)uid;

/**
 * 表示用户的唯一ID。
 */
@property (nonatomic, copy) NSNumber* userId;

@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* pinyinName;
@property (nonatomic, copy) NSString* tinyurl;
@property (nonatomic, copy) NSString* headurl;
@property (nonatomic, copy) NSString* mainurl;
@property (nonatomic, copy) NSString* networkName;

@property (assign) int gossipCount;
@property (assign) int albumCount;
@property (assign) int blogCount;
@property (assign) int star;

/**
 * 表示用户好友数.
 */ 
@property (assign) int friendCount;
/**
 * 表示用户与登录用户的共同好友数.
 * 当前用户默认为0
 */ 
@property (assign) int shareFriendsCount;
@property NSInteger online;

@property BOOL dirty;
@property BOOL lockName;
@property BOOL isChecked;
@property (nonatomic,copy)NSString* usererror;
/**
 * 表示调用的API的类型。
 */
@property (nonatomic) RRApiType apiType;

@end
