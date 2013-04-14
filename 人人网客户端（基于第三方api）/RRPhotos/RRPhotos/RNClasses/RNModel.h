//
//  RNModel.h
//  RRSpring
//
//  Created by hai zhang on 3/6/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// model协议，用于viewController回调
@class RNModel;
@protocol RNModelDelegate <NSObject>

@optional
// 开始
- (void)modelDidStartLoad:(RNModel *)model;
// 完成
- (void)modelDidFinishLoad:(RNModel *)model;
// 错误处理
- (void)model:(RNModel *)model didFailLoadWithError:(RCError *)error;
// 取消
- (void)modelDidCancelLoad:(RNModel *)model;


@end


#pragma mark - RNModel
@interface RNModel : NSObject {
    // 网络请求的必要参数
    NSMutableDictionary *_query;
    // 网络请求的方法名
    NSString *_method;
    // 批处理
    NSMutableArray *_delegates;
    // 网络请求qequest对象
    RCBaseRequest *_request;
    // 网络请求结果，为dictionary或者array类型
    id _result;
    // 分页记录的位置
    NSInteger _currentPageIdx;
    // 分页大小
    NSInteger _pageSize;
    // 返回结果总个数
    NSInteger _total;
    // 返回总数据
    NSMutableArray *_resultAry;
    BOOL _isLoadMore;
}

- (NSMutableArray *)delegates;
/*
 * 发送网络请求
 *
 * @more 是否加载更多
 */
- (void)load:(BOOL)more;

// temporary
- (void)search:(NSString*)text;

// request
- (void)didStartLoad;
- (void)didFinishLoad:(id)result;
- (void)didFailLoadWithError:(NSError*)error;
- (void)didCancelLoad;

@property (nonatomic, retain) NSMutableDictionary *query;
@property (nonatomic, copy) NSString *method;
//@property (nonatomic, retain) NSMutableArray *delegates;
@property (nonatomic, retain) RCBaseRequest *request;
@property (nonatomic, retain) id result;
@property (nonatomic, assign) NSInteger currentPageIdx;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, retain) NSMutableArray *resultAry;
@property (nonatomic, assign) BOOL isLoadMore;

@end
