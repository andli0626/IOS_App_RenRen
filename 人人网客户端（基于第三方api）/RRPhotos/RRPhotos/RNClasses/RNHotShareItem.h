//
//  RNHotShareItem.h
//  RRPhotos
//
//  Created by yi chen on 12-5-14.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNHotShareItem : NSObject
{
	//评论数
	NSNumber *_commentCount;
	//id
	NSNumber *_ID;
	//分享源内容id
	NSNumber *_sourceId;
	//照片的url
	NSString *_photoUrl;
	//分享次数
	NSNumber *_shareCount;
	//分享id
	NSNumber *_shareId;
	//所有者id
	NSNumber *_ownerId;
	//所有者名字
	NSString *_ownerName;
	//时间
	NSDate *_time;
	//下发用户id？不知道什么意思
	NSNumber *_userId;
	
}
@property(nonatomic,copy)NSNumber *commentCount;
@property(nonatomic,copy)NSNumber *ID;
@property(nonatomic,copy)NSNumber *sourceId;
@property(nonatomic,copy)NSString *photoUrl;
@property(nonatomic,copy)NSNumber *shareCount;
@property(nonatomic,copy)NSNumber *shareId;
@property(nonatomic,copy)NSNumber *ownerId;
@property(nonatomic,copy)NSString *ownerName;
@property(nonatomic,retain)NSDate *time;
@property(nonatomic,copy)NSNumber *userId;

/*
	以数据字典格式化
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (id)hotShareItemWithDictionary:(NSDictionary *)dictionary;
@end
