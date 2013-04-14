//
//  RNHotShareItem.m
//  RRPhotos
//
//  Created by yi chen on 12-5-14.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNHotShareItem.h"

@implementation RNHotShareItem

@synthesize commentCount = _commentCount;
@synthesize ID = _ID;
@synthesize sourceId = _sourceId;
@synthesize photoUrl = _photoUrl;
@synthesize shareCount = _shareCount;
@synthesize shareId = _shareId;
@synthesize ownerId = _ownerId;
@synthesize ownerName = _ownerName ;
@synthesize time = _time;
@synthesize userId = _userId;

- (void)dealloc{
	self.commentCount = nil;
	self.ID = nil;
	self.sourceId = nil;
	self.photoUrl = nil;
	self.shareCount = nil;
	self.shareId = nil;
	self.ownerId = nil;
	self.ownerName = nil;
	self.time = nil;
	self.userId = nil;
	
	[super dealloc];
	
}
/*
	以数据字典格式化
 */
- (id)initWithDictionary:(NSDictionary *)dictionary{
	if (self = [super init]) {
		self.commentCount = [dictionary objectForKey:@"comment_count"];
		self.ID = [dictionary objectForKey:@"id"]; //分享id
		self.sourceId = [dictionary objectForKey:@"source_id"];//分享源内容id
		self.photoUrl = [dictionary objectForKey:@"photo"];
		self.shareCount = [dictionary objectForKey:@"share_count"];
		self.shareId = [dictionary objectForKey:@"share_id"];
		self.ownerId = [dictionary objectForKey:@"source_owner_id"];
		self.ownerName = [dictionary objectForKey:@"source_owner_name"];
		self.time = [dictionary objectForKey:@"time"];
		self.userId = [dictionary objectForKey:@"user_id"];
	}
	return self;
}

+ (id)hotShareItemWithDictionary:(NSDictionary *)dictionary{
	RNHotShareItem *item = [[RNHotShareItem alloc]initWithDictionary:dictionary];
	return [item autorelease];
}
@end
