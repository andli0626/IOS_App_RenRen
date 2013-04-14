//
//  RNNewsFeedModel.h
//  RRPhotos
//
//  Created by yi chen on 12-4-13.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNModel.h"
#import "RRNewsFeedItem.h"
@interface RNNewsFeedModel : RNModel
{
	//新鲜事总数
	NSInteger _newsFeedCount;
	
	//新鲜事容器,里面的实例是 RRNewsFeedItem
	NSMutableArray *_newsFeeds;
}

@property(nonatomic)NSInteger newsFeedCount;
@property(nonatomic,retain)NSMutableArray *newsFeeds;

/*
	types: 新鲜事类型数组，RRNewsfeedType的String
 */
- (id)initWithTypes:(NSArray *)types;

/*
	typeString:新鲜事RRNewsfeedType，多个类型以逗号隔开
 */
- (id)initWithTypeString:(NSString *)typeString;

/*
	typeString:新鲜事RRNewsfeedType，多个类型以逗号隔开
	userId: 取新鲜事的用户id
 */
- (id)initWithTypeString:(NSString *)typeString userId:(NSNumber *)userId;
@end
