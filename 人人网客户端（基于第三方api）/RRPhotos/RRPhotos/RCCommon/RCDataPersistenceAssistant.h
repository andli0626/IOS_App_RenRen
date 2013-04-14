//
//  RCDataPersistenceAssistant.h
//  RRSpring
//
//  Created by gaosi on 12-3-29.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "RRCouchDBServer.h"
#import "RCLBSCacheManager.h"

@interface RCDataPersistenceAssistant : NSObject{

}

+ (void)clearAllData;
+ (void)saveFriendList:(NSArray *)array;
+ (NSArray *)getFriendList;
+ (void)saveFriendListWithDB:(NSArray *)array;
+ (NSArray *)getFriendListFromDB;
+ (void)saveCurrentLocationPOICache:(RCCurrentLocationPOICache *)cache;
+ (RCCurrentLocationPOICache *)getCurrentLocationPOICache;
+ (void)savePhotoLocationPOICache:(RCPhotoLocationPOICache *)cache;
+ (RCPhotoLocationPOICache *)getPhotoLocationPOICache;
+ (void)saveLocationCache:(RCLocationCache *)cache;
+ (RCLocationCache *)getLocationCache;

// 消息的持久化
+ (void)saveReplyMessageList:(NSArray*)array;
+ (NSArray*)getReplyMessageList;

+ (void)saveBirthdayReminderList:(NSArray*)array;
+ (NSArray*)getBirthdayReminderList;

+ (void)saveFriendRequestList:(NSArray*)array;
+ (NSArray*)getFriendRequestList;

+ (void)addOneReplyMessage:(NSDictionary*)dic;
+ (void)addOneBirthdayReminder:(NSDictionary*)dic;
+ (void)addOneFriendRequest:(NSDictionary*)dic;
+ (void)deleteOneReplyMessage:(NSDictionary*)dic;
+ (void)deleteOneBirthdayReminder:(NSDictionary*)dic;
+ (void)deleteOneFriendRequest:(NSDictionary*)dic;
// 默认表情数据的
+(void)saveDefauleEmotion:(NSDictionary*)emotionlist;
+(NSDictionary*)getDefauleEmotionList;

// 缓存特别关注好友
+ (void)saveFocusFriendsList:(NSArray*)array;
+ (NSArray*)getFocusFriendsList;
@end
