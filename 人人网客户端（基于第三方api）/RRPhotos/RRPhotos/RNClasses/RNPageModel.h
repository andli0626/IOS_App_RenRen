//
//  RNPageModel.h
//  RRSpring
//
//  Created by sheng siglea on 4/6/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNModel.h"

@interface RNPageModel : RNModel{
    /**
     * 分页列表数据项
     */
	NSMutableArray* _items;	
    /**
     * 数据总数
     */
    NSInteger _totalItem;
    /**
     * 总页数
     */
    NSInteger _totalPage;
    /**
     * 加载更多
     */
    BOOL _loadMore;
}

@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic, assign,readonly)NSInteger totalPage;
@property (nonatomic, assign) NSInteger totalItem;
@property (nonatomic, assign) BOOL loadMore;

@end
