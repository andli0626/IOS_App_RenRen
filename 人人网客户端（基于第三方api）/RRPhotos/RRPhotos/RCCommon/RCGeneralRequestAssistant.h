//
//  RCGeneralRequestAssistant.h
//  RRSpring
//
//  Created by jiachengwen on 12-2-16.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCBlocks.h"

@interface RCGeneralRequestAssistant : MKNetworkEngine
{
    MKNetworkOperation* operation;
    NSMutableDictionary* _fields;
}

/**
 * 请求参数
 */
@property (nonatomic, retain) NSMutableDictionary* fields;

/**
 * 请求完成回调
 */
@property (nonatomic, copy) onCompletionBlock onCompletion;

/**
 * 错误回调
 */
@property (nonatomic, copy) onErrorBlock onError;

/**
 * 快捷生成器
 */
+(RCGeneralRequestAssistant*)requestAssistant;

/**
 * 发送请求
 */
-(void)sendQuery:(NSDictionary *)query withMethod:(NSString*)method;

/**
 * 取消请求
 */
-(void)cancelRequest;

@end
