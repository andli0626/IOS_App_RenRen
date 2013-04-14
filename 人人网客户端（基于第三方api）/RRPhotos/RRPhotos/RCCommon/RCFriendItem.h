//
//  RRFriendItem.h
//  RRSpring
//
//  Created by yi chen on 12-2-27.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark --
#pragma mark FriendItem
///////////////////////////////////////////////////////////////////////////////////////////////////
//好友列表item
@interface RCFriendItem : NSObject
{
	NSString *_headUrl;     //头像地址
	NSString *_networkName; //网络关系名字
	NSString *_userName;    //用户名字
    NSNumber *_uid;         //用户id
	NSString *_group;       //用户分组信息
    NSString *_gender;      //用户性别
    NSString *_status;      //用户最近状态
	BOOL _onLine;           //在线信息
    BOOL _isFriend;         //与当前用户是否为好友
    BOOL _alreadyAdd;       //是否已申请好友
    BOOL _fromAt;           //是否来自@的点击
    BOOL _selected;         //在@中是否被选择	
    
}

@property (nonatomic,copy)NSNumber *uid;
@property (nonatomic,copy)NSString *headUrl;
@property (nonatomic,copy)NSString *networkName;
@property (nonatomic,copy)NSString *userName;
@property (nonatomic,copy)NSString *gender;
@property (nonatomic,copy)NSString *group;
@property (nonatomic,copy)NSString *status;
@property BOOL onLine;
@property BOOL isFriend;
@property BOOL alreadyAdd;
@property BOOL fromAt;
@property BOOL selected;

-(id)initWithDicInfo:(NSDictionary *)friendDic;
+ (id)itemWithDicInfo:(NSDictionary *)friendDic;

@end



