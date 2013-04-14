//
//  RNNewsFeedModel.m
//  RRPhotos
//
//  Created by yi chen on 12-4-13.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNNewsFeedModel.h"
#import "RRNewsFeedItem.h"
#define kMaxNewsFeedCount 500
@implementation RNNewsFeedModel

@synthesize newsFeedCount = _newsFeedCount;
@synthesize newsFeeds = _newsFeeds;

- (void)dealloc{
	self.newsFeedCount = 0;
	self.newsFeeds = nil;
	[super dealloc];
}

- (id)init{
	if (self = [super init]) {
		self.newsFeeds = nil;
		self.newsFeedCount = 0;
	}
	return self;
}


/*
	types: 新鲜事类型数组，RRNewsfeedType的String
 */
- (id)initWithTypes:(NSArray *)types{
	if (self = [self init]) {
		if (types && [types count] != 0) {
			NSMutableString *typeString = [[NSMutableString alloc]init];
			
			for (id object in types) {
				NSString *subTypeString = (NSString *)object;
				[typeString appendString: subTypeString];
			}
			
			[self.query setObject:typeString forKey:@"type"];
			[self.query setObject:[NSNumber numberWithInt:kMaxNewsFeedCount] forKey:@"page_size"];
			self.method = @"feed/get";
		}
	}
	
	return self;
}


/*
	typeString:新鲜事RRNewsfeedType，多个类型以逗号隔开
 */
- (id)initWithTypeString:(NSString *)typeString{
	if(self = [self init]){
		if (typeString && ![typeString isEqualToString:@""]) {
			[self.query setObject:typeString forKey:@"type"];
			[self.query setObject:[NSNumber numberWithInt:kMaxNewsFeedCount] forKey:@"page_size"];
			self.method = @"feed/get";
		}
	}
	return self;
}

/*
	typeString:新鲜事RRNewsfeedType，多个类型以逗号隔开
	userId: 取新鲜事的用户id
 */
- (id)initWithTypeString:(NSString *)typeString userId:(NSNumber *)userId{
	if (self = [self initWithTypeString:typeString]) {
		if (userId) {
			[self.query setObject:userId forKey:@"uid"];
		}
	}
	return self;
}

/*
	加载数据
 */
- (void)load:(BOOL)more {
    
//	if (more) {
//		//分页加载
//	}else {
		[super load:more];
//	}
}

/*
	清空数据
 */
- (void)clearData{
	self.newsFeeds = nil;
	self.newsFeedCount = 0;
}

/*
	网络加载成功回调，此处覆盖了父类的方法
 */
- (void)didFinishLoad:(id)result {
	if (!result) {
		return;
	}
	
	NSDictionary* resultDic = (NSDictionary *)result;
	NSLog(@"最初的数据是：%@",result);
	
	NSArray *feedList = [resultDic objectForKey:@"feed_list"];
	
	[self clearData]; //先清除数据
	_newsFeeds = [[NSMutableArray alloc]initWithCapacity:kMaxNewsFeedCount];
	for (id feedItem in feedList ) {
		if ([feedItem isKindOfClass:NSDictionary.class] ) {
			RRNewsFeedItem *newsFeedItem = [RRNewsFeedItem newsfeedWithDictionary:(NSDictionary *) feedItem];
			if (newsFeedItem) {
				[self.newsFeeds  addObject:newsFeedItem];
			}
		}
	} 
	_resultAry = self.newsFeeds; //记录用于分页加载
	
	self.newsFeedCount = [self.newsFeeds count];
	
   [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}


@end
