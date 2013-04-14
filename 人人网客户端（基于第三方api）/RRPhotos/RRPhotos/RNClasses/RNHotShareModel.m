//
//  RNExploreModel.m
//  RRPhotos
//
//  Created by yi chen on 12-5-11.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNHotShareModel.h"
@implementation RNHotShareModel
@synthesize hotShareItems = _hotShareItems;
- (void)dealloc{
	self.hotShareItems = nil;
	[super dealloc];
}

- (id)init{
	if (self = [super init]) {
		
	}
	
	return  self;
}

/*
	typeString:新鲜事RRNewsfeedType，多个类型以逗号隔开
 */
- (id)initWithTypeString:(NSString *)typeString{
	if(self = [self init]){
		if (typeString && ![typeString isEqualToString:@""]) {
			[self.query setObject:typeString forKey:@"type"];
			[self.query setObject:[NSNumber numberWithInt:kHotSharePhotoCountMax] forKey:@"page_size"];
			self.method = @"share/getHots";
			self.total = 1000;
			self.pageSize = kHotSharePhotoCountMax; //每次请求的热门分享条数
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
	网络加载完成回调
 */
- (void)didFinishLoad:(id)result {
	if (!result) {
		return;
	}
	NSLog(@"获取热门分享结果如下：%@",result);

	if ([result objectForKey:@"item_list"]) {
		NSArray *items = [result objectForKey:@"item_list"];
		TT_RELEASE_SAFELY(_hotShareItems);
		_hotShareItems = [[NSMutableArray alloc]initWithArray:items];
	}
	[_resultAry addObjectsFromArray:_hotShareItems];
	
	[_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}
@end
