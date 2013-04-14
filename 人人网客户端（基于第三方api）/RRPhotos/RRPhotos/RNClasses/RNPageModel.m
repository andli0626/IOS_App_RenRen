//
//  RNPageModel.m
//  RRSpring
//
//  Created by sheng siglea on 4/6/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNPageModel.h"

@implementation RNPageModel
@synthesize items = _items;
@synthesize totalItem = _totalItem;
@synthesize totalPage = _totalPage;
@synthesize loadMore = _loadMore;

-(id)init{
    if (self = [super init]) {
        self.pageSize = 30;
        self.items = [NSMutableArray array];
        self.loadMore = NO;
    }
    return self;
}
- (void)dealloc{
    self.items = nil;
    [super dealloc];
}
- (void)load:(BOOL)more {
    self.loadMore = more;
    if (self.method == nil) {
        return;
    }
    if (more) {
        self.currentPageIdx ++;
    }else {
        self.currentPageIdx = 1;
        self.totalItem = 0;
    }
    [_query setObject:[NSNumber numberWithInteger:self.currentPageIdx] forKey:@"page"];
    [_request sendQuery:_query withMethod:_method];
    [self didStartLoad];
}

- (void)didFinishLoad:(id)result{
    if (!self.loadMore) {
        [self.items removeAllObjects];
    }
//    在子类中实现
//    self.result = result;
//    self.totalItem = [result intForKey:@"count" withDefault:0];
//    self.title = [result stringForKey:@"album_name" withDefault:@""];
//    _totalPage = (self.totalItem + self.pageSize - 1)/self.pageSize;  
}
@end
