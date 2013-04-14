//
//  RNAtFriendsModel.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-1.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNModel.h"
/**
 * 好友类型
 */
typedef enum {
	ENearlyFriendType, //最近@的好友
	ENormalFriendType, //普通全部好友
    EPublicFriendType  //公共主页
} AtFriendType;

@interface RNAtFriendsModel : RNModel{
	NSMutableArray *_chatPersons;
	NSInteger _chatPersonsCount;
    NSMutableArray* _chatSectionPersons;
    BOOL _fromCache;
    NSInteger _sectionCount;
    AtFriendType _friendsType;
    //公共主页数据
    NSMutableArray *_pagePersons;
    NSMutableArray* _pageSectionPersons;
    //选择的数据存放变量
    NSMutableDictionary *_atFriendData;
    //搜索的当前数据
    NSMutableArray *_searchData;
    //用于获取共同好友
    NSNumber  *_ownerId;
    //用于常用@好友
    NSMutableArray *_nearlyatPersons;
   // NSMutableArray* _nearlySectionPersons;
    

}
@property (nonatomic, retain) NSMutableArray *nearlyatPersons;
//@property (nonatomic, retain) NSMutableArray *nearlySectionPersons;

@property (nonatomic, retain) NSMutableArray *chatPersons;
@property (nonatomic, retain) NSMutableArray *chatSectionPersons;
@property (nonatomic, assign) NSInteger chatPersonsCount;
@property (nonatomic, assign) BOOL fromCache;
@property (nonatomic, assign) NSInteger sectionCount;
@property (nonatomic, assign) AtFriendType friendsType;
@property (nonatomic, retain) NSNumber *ownerId;
@property (nonatomic,retain)  NSMutableDictionary *atFriendData;

//公共主页数据
@property (nonatomic, retain) NSMutableArray *pagePersons;
@property (nonatomic, retain) NSMutableArray *pageSectionPersons;
//搜索的数据
@property (nonatomic,assign)  NSMutableArray *searchData;

- (id)initWithUserId:(NSNumber *)userId;
- (void)search:(NSString*)text;
//加载好友缓存列表
- (void)loadCacheData;
//选中数据操作
-(BOOL)addAtFriendData:(id)keys value:(id)val;
-(void)removeAtFriendDataForKey:(id)key;
-(BOOL)findAtFriendDataForKey:(id)key;
-(void)removeAtFriendDataForobj:(id)val;
@end


















