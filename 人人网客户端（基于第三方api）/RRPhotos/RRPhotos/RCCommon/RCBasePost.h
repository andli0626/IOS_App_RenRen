//
//  RCBasePost.h
//  RRSpring
//
//  Created by jiachengwen on 12-2-28.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCBasePost;

typedef enum {
    EPostStateReady = 1,
    EPostStateExecuting = 2,
    EPostStateFinished = 3,
    EPostStateError = 4
} RCPostEnumState;

typedef enum {
    EPostTypeNone = 0,
    EPostTypePhoto = 1,
    EPostTypeBlog = 2
} RCPostItemType;

#define kPostTypeWebView @"PostTypeWebView"

/* --------------------------------------------------------- */
/*         网络状态类                                          */
/* --------------------------------------------------------- */
@interface RCPostState : NSObject

/**
 * 状态码
 */
@property (nonatomic) RCPostEnumState ePostState;

/**
 * 网络错误码
 */
@property (nonatomic, copy) NSString* error;

/**
 * 发送标题
 */
@property (nonatomic, copy) NSString* title;

/**
 * 发送描述
 */
@property (nonatomic, copy) NSString* sendTime;

/**
 * 缩略图
 */
@property (nonatomic, copy) UIImage* thumbnails;

/**
 * post的类型
 */
@property (nonatomic) RCPostItemType itemType;

/**
 * 是否可从发送队列中删除
 */
@property (nonatomic) BOOL canRemoveFromQueue;

@property (nonatomic, readonly) NSString* uniqueID;

@end


/**
 * 当前发送的状态变化。失败时error != nil, 否则error = nil。
 */
typedef void (^PostStateChangedBlock)(RCBasePost* basePost);


/* -------------------------------------------------------- */
/*         本类设计为并发发送或线性发送操作的基类，其他类             */
/*         继承自本类后或得进入发送队列能力                        */
/*         主要封装了：                                        */
/*                  1.状态变化时通知机                          */
/*                  2.发送时进入到并行和非并行队列的选择            */
/* --------------------------------------------------------- */

@interface RCBasePost : MKNetworkOperation

/**
 * 记录当前post的状态
 */
@property (nonatomic, retain) RCPostState* postState;

/**
 * 状态变化函数块，用于通知外部
 */
@property (nonatomic, copy) PostStateChangedBlock postStateChanged;

@end
