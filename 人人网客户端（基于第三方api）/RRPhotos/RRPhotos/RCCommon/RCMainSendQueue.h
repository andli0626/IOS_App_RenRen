//
//  RCMainSendQueue.h
//  RRSpring
//
//  Created by jiachengwen on 12-2-28.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCBasePost.h"

// 放在。h里是为了方便其他地方引用这个宏
#define kMainSendQueueStatusChanged @"MainSendQueueStatusChanged"

#define kMainSendQueueStatusBarMessage @"MainSendQueueStatusBarMessage"

/* --------------------------------------------------------- */
/*         总发送队列，包含两个内部队列管理。一个并发队列，最多并发5个.   */
/*         另一个顺序发送队列。比如发送图片。                        */
/* --------------------------------------------------------- */

@interface RCMainSendQueue : MKNetworkEngine {
    @private
    NSMutableArray* _singleDispatch;
    NSMutableArray* _multiDispatch;
    NSMutableArray* _errorStateOfPost;
    
    RCBasePost* _currentSinglePost;
    NSMutableDictionary* _currentMultiPost;
    
    BOOL _isInLunching;
}

@property (nonatomic, retain) RCBasePost* currentSinglePost;

/**
 * 获取发送队列的单例对象
 */
+ (RCMainSendQueue *)sharedMainQueue;

/**
 * 添加到并发队列
 */
- (void)addToConcurrentQueue:(RCBasePost *) postOperation;

/**
 * 添加到线性发送队列
 */
- (void)addToLinearQueue:(RCBasePost *) postOperation;

/**
 * 添加到线性发送队列
 */
- (void)addToErrorStateQueue:(RCPostState *) state;

/**
 * 清除发送队列
 */
- (void)removeAllPostOperation;

/**
 * 清除单条
 */
- (void)removePostByIdentifier:(NSString*)uniqueID;

/**
 * 获取发送列表
 */
- (NSMutableDictionary*)listAllPostOperations;

/**
 * 处理并发队列：判断是否添加到mk的queue里。
 */
- (void)dealWithConcurrentQueue;

/**
 * 处理线性队列：判断是否添加到mk的queue里。
 */
- (void)dealWithLinearQueue;

/**
 * 当post的状态发生变化或队列发生变化时发送全局通知消息。
 */
- (void)postStatusChangeMessageToGlobal;

/**
 * 向statusbar发送变化消息
 */
- (void)postStatusToStatusBar:(BOOL)isAddnew;

/**
 * 队列本地存储路径。
 */
- (NSString*)cacheSendQueueDirectoryName;

/**
 * 队列存储初始化。
 */
- (void)canFreezeQueue;

/**
 * 队列存储到磁盘。
 */
- (void)saveSendQueue;

/**
 * 从磁盘恢复队列。
 */
- (void)restoreFrozenQueueIfNeed;

@end
