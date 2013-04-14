//
//  RCDataPersistenceAssistant.m
//  RRSpring
//
//  Created by gaosi on 12-3-29.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCDataPersistenceAssistant.h"
#import "RCConfig.h"
//#import "RRCouchDBServer.h"

#define kFriendsDefault @"friendList"
#define kFriendsDataVersion  @"kFriendsDataVersion"
#define kFriendsDBDataName @"friendslistdb"
#define kCurrentLocationPOICache @"currentLocationPOICache"
#define kCurrentLocationPOICacheDataVersion @"currentLocationPOICacheDataVersion"
#define kPhotoLocationPOICache @"photoLocationPOICache"
#define kPhotoLocationPOICacheDataVersion @"photoLocationPOICacheDataVersion"
#define kLocationCache @"locationCache"
#define kLocationCacheDataVersion @"locationCacheDataVersion"
#define kMessageList @"messageList"
#define kMessageListDataVersion @"messageListDataVersion"
#define kBirthdayReminderList @"birthdayReminderList"
#define kBirthdayReminderListDataVersion @"birthdayReminderListDataVersion"
#define kFriendRequestList @"friendRequestList"
#define kFriendRequestListDataVersion @"friendRequestListDataVersion"

#define kEmotionListVersion @"emotionListVersion"
#define kEmotionList @"emotionlist"

#define kFocusFriendsList @"focusFriendsList"
#define kFocusFriendsListDataVersion @"focusFriendsListDataVersion"

//extern CouchbaseMobile *sCouchbase;
//static RRCouchDBServer *rrCouchDBServer = nil;

@implementation RCDataPersistenceAssistant

+ (void)clearAllData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentLocationPOICache];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPhotoLocationPOICache];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocationCache];
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]] autorelease];
    [defaults removeObjectForKey:kFriendsDefault];
    [defaults removeObjectForKey:kMessageList];
    [defaults removeObjectForKey:kBirthdayReminderList];
    [defaults removeObjectForKey:kFriendRequestList];
    [defaults removeObjectForKey:kEmotionList];
}

+ (void)saveFriendList:(NSArray *)array
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。 
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]] autorelease];
    [defaults setObject:productVersion forKey:kFriendsDataVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [defaults setObject:data forKey:kFriendsDefault];
}

+ (NSArray *)getFriendList
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; // 也可以从info.plist中读取
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]] autorelease];
    NSString *friendDataVersion = [defaults objectForKey:kFriendsDataVersion];
    if (!friendDataVersion || ![friendDataVersion isEqualToString:productVersion] ) {
        [defaults removeObjectForKey:kFriendsDefault];
        return nil;
    }
    NSData *data = [defaults objectForKey:kFriendsDefault];
    NSArray *friendArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	return friendArray;
}
// chenyi modify 12-5-1 去掉db
//+ (void)initDBServer
//{
//    if(!rrCouchDBServer){
//        rrCouchDBServer = [[RRCouchDBServer alloc] initWithCouchbaseMobile:sCouchbase];
//    }
//}
//
//+ (void)initDBWithName:(NSString*)name
//{
//    [RCDataPersistenceAssistant initDBServer];
//    [rrCouchDBServer createDBWithName:name];
//}

//+ (void)saveFriendListWithDB:(NSArray *)array
//{
//    [RCDataPersistenceAssistant initDBWithName:kFriendsDBDataName];
//    int count = [array count];
//    for(int i=0;i<count;i++){
//        NSMutableDictionary* data = [array objectAtIndex:i];
//        NSLog(@"save data:%@",data);
//        [rrCouchDBServer putDataToCouchServer:kFriendsDBDataName document:[NSString stringWithFormat: @"friendslistdata%d",i] data:data];
//    }
//}

//+ (NSArray *)getFriendListFromDB
//{
//    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
//    int i=0;
//    while (true) {
//        NSDictionary* data = [rrCouchDBServer getDataFromCouchServer:kFriendsDBDataName document:[NSString stringWithFormat: @"friendslistdata%d",i]];
//        NSLog(@"get data:%@",data);
//        if(data && [data objectForKey:@"error"] == nil){
//            [array addObject:data];
//            i++;
//        }
//        else {
//            break;
//        }
//    }
//    return array;
//}
//
+ (void)saveCurrentLocationPOICache:(RCCurrentLocationPOICache *)cache
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。
    // 也可以从info.plist中读取
    //    [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];  
    [[NSUserDefaults standardUserDefaults] setObject:productVersion forKey:kCurrentLocationPOICacheDataVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cache];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentLocationPOICache];
}

+ (RCCurrentLocationPOICache *)getCurrentLocationPOICache
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; // 也可以从info.plist中读取
    //[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]; 
    NSString *friendDataVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentLocationPOICacheDataVersion];
    if (!friendDataVersion || ![friendDataVersion isEqualToString:productVersion] ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentLocationPOICache];
        return nil;
    }
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentLocationPOICache];
    RCCurrentLocationPOICache *cache = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	return cache;
}

+ (void)savePhotoLocationPOICache:(RCPhotoLocationPOICache *)cache
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。
    // 也可以从info.plist中读取
    //    [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];  
    [[NSUserDefaults standardUserDefaults] setObject:productVersion forKey:kCurrentLocationPOICacheDataVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cache];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentLocationPOICache];
}

+ (RCPhotoLocationPOICache *)getPhotoLocationPOICache
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; // 也可以从info.plist中读取
    //[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]; 
    NSString *friendDataVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kPhotoLocationPOICacheDataVersion];
    if (!friendDataVersion || ![friendDataVersion isEqualToString:productVersion] ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPhotoLocationPOICache];
        return nil;
    }
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kPhotoLocationPOICache];
    RCPhotoLocationPOICache *cache = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	return cache;
}

+ (void)saveLocationCache:(RCLocationCache *)cache
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。
    // 也可以从info.plist中读取
    //    [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];  
    [[NSUserDefaults standardUserDefaults] setObject:productVersion forKey:kLocationCacheDataVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cache];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kLocationCache];
}

+ (RCLocationCache *)getLocationCache
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; // 也可以从info.plist中读取
    //[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]; 
    NSString *friendDataVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kLocationCacheDataVersion];
    if (!friendDataVersion || ![friendDataVersion isEqualToString:productVersion] ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocationCache];
        return nil;
    }
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kLocationCache];
    RCLocationCache *cache = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	return cache;
}

+ (void)saveReplyMessageList:(NSArray*)array
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]];
    [defaults setObject:productVersion forKey:kMessageListDataVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [defaults setObject:data forKey:kMessageList];
}

+ (NSArray*)getReplyMessageList
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; // 也可以从info.plist中读取
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]];
    NSString *messageListDataVersion = [defaults objectForKey:kMessageListDataVersion];
    if (!messageListDataVersion || ![messageListDataVersion isEqualToString:productVersion] ) {
        [defaults removeObjectForKey:kMessageList];
        return nil;
    }
    NSData *data = [defaults objectForKey:kMessageList];
    NSArray *messageListArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	return messageListArray;    
}

+ (void)saveBirthdayReminderList:(NSArray*)array
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。 
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]];
    [defaults setObject:productVersion forKey:kBirthdayReminderListDataVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [defaults setObject:data forKey:kBirthdayReminderList];
}

+ (NSArray*)getBirthdayReminderList
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; // 也可以从info.plist中读取
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]];
    NSString *messageListDataVersion = [defaults objectForKey:kBirthdayReminderListDataVersion];
    if (!messageListDataVersion || ![messageListDataVersion isEqualToString:productVersion] ) {
        [defaults removeObjectForKey:kBirthdayReminderList];
        return nil;
    }
    NSData *data = [defaults objectForKey:kBirthdayReminderList];
    NSArray *messageListArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	return messageListArray;    
}

+ (void)saveFriendRequestList:(NSArray*)array
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。 
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]] autorelease];
    [defaults setObject:productVersion forKey:kFriendRequestListDataVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [defaults setObject:data forKey:kFriendRequestList];
}

+ (NSArray*)getFriendRequestList
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; // 也可以从info.plist中读取
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]] autorelease];
    NSString *messageListDataVersion = [defaults objectForKey:kFriendRequestListDataVersion];
    if (!messageListDataVersion || ![messageListDataVersion isEqualToString:productVersion] ) {
        [defaults removeObjectForKey:kFriendRequestList];
        return nil;
    }
    NSData *data = [defaults objectForKey:kFriendRequestList];
    NSArray *messageListArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	return messageListArray;    
}

+ (void)addOneReplyMessage:(NSDictionary*)dic
{
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    NSArray* replyList = [RCDataPersistenceAssistant getReplyMessageList];
    if(replyList){
        // TODO：需要对上限做限制
        [array addObjectsFromArray:replyList];
    }
    [array insertObject:dic atIndex:0];
    
    [RCDataPersistenceAssistant saveReplyMessageList:array];
}

+ (void)addOneBirthdayReminder:(NSDictionary*)dic
{
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    NSArray* birthdayList = [RCDataPersistenceAssistant getBirthdayReminderList];
    if(birthdayList){
        // TODO：需要对上限做限制
        [array addObjectsFromArray:birthdayList];
    }
    [array insertObject:dic atIndex:0];
    
    [RCDataPersistenceAssistant saveBirthdayReminderList:array];
}

+ (void)addOneFriendRequest:(NSDictionary*)dic
{
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    NSArray* friendReqList = [RCDataPersistenceAssistant getFriendRequestList];
    if(friendReqList){
        // TODO：需要对上限做限制
        [array addObjectsFromArray:friendReqList];
    }
    [array insertObject:dic atIndex:0];
    
    [RCDataPersistenceAssistant saveFriendList:array];
}
+ (void)deleteOneReplyMessage:(NSDictionary*)dic
{
    NSArray* list = [RCDataPersistenceAssistant getReplyMessageList];
    NSMutableArray* listArray = [NSMutableArray arrayWithArray:list];
    id dicId = [dic objectForKey:@"id"];
    for(NSDictionary* dicInfo in listArray){
        id srcId = [dicInfo objectForKey:@"id"];
        if([dicId isKindOfClass:[NSNumber class]] && [srcId isKindOfClass:[NSNumber class]]){
            if([dicId longValue] == [srcId longValue]){
                [listArray removeObject:dicInfo];
                [RCDataPersistenceAssistant saveReplyMessageList:listArray];
                return;
            }
        }
        else if([dicId isKindOfClass:[NSArray class]] && [srcId isKindOfClass:[NSArray class]]){
            if([dicId count] == [srcId count]){
                int count = [dicId count];
                BOOL isSame = NO;
                for(int i=0;i<count;i++){
                    NSNumber* numDicId = [dicId objectAtIndex:i];
                    NSNumber* numSrcId = [srcId objectAtIndex:i];
                    if([numDicId longValue] != [numSrcId longValue]){
                        isSame = NO;
                        break;
                    }
                    else{
                        isSame = YES;
                    }
                }
                if(isSame){
                    [listArray removeObject:dicInfo];
                    [RCDataPersistenceAssistant saveReplyMessageList:listArray];
                    return;
                }
            }
        }
    }
}

+ (void)deleteOneBirthdayReminder:(NSDictionary*)dic
{
    NSArray* list = [RCDataPersistenceAssistant getBirthdayReminderList];
    NSMutableArray* listArray = [NSMutableArray arrayWithArray:list];
    id dicId = [dic objectForKey:@"id"];
    for(NSDictionary* dicInfo in list){
        id srcId = [dicInfo objectForKey:@"id"];
        if([dicId isKindOfClass:[NSNumber class]] && [srcId isKindOfClass:[NSNumber class]]){
            if([dicId longValue] == [srcId longValue]){
                [listArray removeObject:dicInfo];
                [RCDataPersistenceAssistant saveBirthdayReminderList:listArray];
                return;
            }
        }
        else if([dicId isKindOfClass:[NSArray class]] && [srcId isKindOfClass:[NSArray class]]){
            if([dicId count] == [srcId count]){
                while([dicId nextObject]){
                    if([[dicId nextObject] longValue] != [[srcId nextObject] longValue])
                        break;
                }
                [listArray removeObject:dicInfo];
                [RCDataPersistenceAssistant saveBirthdayReminderList:listArray];
                return;
            }
        }
    }
}

+ (void)deleteOneFriendRequest:(NSDictionary*)dic
{
    NSArray* list = [RCDataPersistenceAssistant getFriendRequestList];
    NSMutableArray* listArray = [NSMutableArray arrayWithArray:list];
    id dicId = [dic objectForKey:@"id"];
    for(NSDictionary* dicInfo in list){
        id srcId = [dicInfo objectForKey:@"id"];
        if([dicId isKindOfClass:[NSNumber class]] && [srcId isKindOfClass:[NSNumber class]]){
            if([dicId longValue] == [srcId longValue]){
                [listArray removeObject:dicInfo];
                [RCDataPersistenceAssistant saveFriendRequestList:listArray];
                return;
            }
        }
        else if([dicId isKindOfClass:[NSArray class]] && [srcId isKindOfClass:[NSArray class]]){
            if([dicId count] == [srcId count]){
                while([dicId nextObject]){
                    if([[dicId nextObject] longValue] != [[srcId nextObject] longValue])
                        break;
                }
                [listArray removeObject:dicInfo];
                [RCDataPersistenceAssistant saveFriendRequestList:listArray];
                return;
            }
        }
    }
}

+(void)saveDefauleEmotion:(NSDictionary*)emotionlist{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。 
    [[NSUserDefaults standardUserDefaults] setObject:productVersion forKey:kEmotionListVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:emotionlist];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kEmotionList];
}
+(NSDictionary*)getDefauleEmotionList{

    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; // 也可以从info.plist中读取
    NSString *messageListDataVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kEmotionListVersion];
    if (!messageListDataVersion || ![messageListDataVersion isEqualToString:productVersion] ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEmotionList];
        return nil;
    }
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kEmotionList];
    NSDictionary *messageListArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	return messageListArray; 
}

+ (void)saveFocusFriendsList:(NSArray*)array
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; //用产品版本号作为数据版本号。 
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]] autorelease];
    [defaults setObject:productVersion forKey:kFocusFriendsListDataVersion];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [defaults setObject:data forKey:kFocusFriendsList];
}

+ (NSArray*)getFocusFriendsList
{
    RCConfig *config = (RCConfig*)[RCConfig globalConfig];
    NSString *productVersion = config.version; // 也可以从info.plist中读取
    RCMainUser *mainUser = [RCMainUser getInstance];
    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithUser:[mainUser.userId stringValue]] autorelease];
    NSString *friendDataVersion = [defaults objectForKey:kFocusFriendsListDataVersion];
    if (!friendDataVersion || ![friendDataVersion isEqualToString:productVersion] ) {
        [defaults removeObjectForKey:kFocusFriendsList];
        return nil;
    }
    NSData *data = [defaults objectForKey:kFocusFriendsList];
    NSArray *friendArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	return friendArray;
}

@end
