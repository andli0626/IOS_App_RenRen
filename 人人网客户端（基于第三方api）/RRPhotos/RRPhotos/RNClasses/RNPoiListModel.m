
//
//  RNPoiListModel.m
//  RRSpring
//
//  Created by yi chen on 12-4-16.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPoiListModel.h"

//定位半径
#define kRNPoiListModelLocationRadius 100 
//每页条数
#define kRNPoiListModelPageSize 10
@implementation RNPoiListModel

- (void)dealloc{
	[super dealloc];
}

- (id)init{
	if (self = [super init]) {
		self.method = @"place/poiList"; 
		self.pageSize = kRNPoiListModelPageSize;
		self.items = [NSMutableArray array];
	}
	return self;
}
/*
	加载数据
	more:是否分页
 */
- (void)load:(BOOL)more{
	//每页条数
	[self.query setObject:[NSNumber numberWithInt: self.pageSize] forKey:@"page_size"];
	//使用的是否是真实经纬度，若是，则设1，若已经使用的是偏转过的经纬度，则设为0
	[self.query setObject:[NSNumber numberWithInt:0] forKey:@"d"];
	//查找半径，单位为米
	[self.query setObject:[NSNumber numberWithInt:kRNPoiListModelLocationRadius] forKey:@"radius"];
	if (more && self.currentPageIdx == 0) {
		self.currentPageIdx = 1; //跳过第一页 加载
	}
	[super load:more];
}
#pragma mark - 网络回调
- (void)didStartLoad {
    [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
}

- (void)didFinishLoad:(id)result {
    self.result = result;
	NSLog(@"cy --------- poi列表请求结果%@",result);
	self.totalItem = [result intForKey:@"count" withDefault:0];
    _totalPage = (self.totalItem + self.pageSize - 1)/self.pageSize; //所有的页数
    NSArray *poiListArray = [result objectForKey:@"poi_list"];
    for (NSDictionary *dict in poiListArray) {
		//存储poi列表
		NSDictionary *item = [[NSDictionary alloc]initWithDictionary:dict];
        [self.items addObject:item];
		TT_RELEASE_SAFELY(item);
    }
	
    if ([self.items count] >= self.totalItem) {
        self.currentPageIdx = _totalPage;
    }
	
	
    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}


- (void)didFailLoadWithError:(RCError *)error {
    [_delegates perform:@selector(model:didFailLoadWithError:) withObject:self
             withObject:error];
}

- (void)didCancelLoad {
    [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}

@end
