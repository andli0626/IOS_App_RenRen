//
//  RCBaseRequest.h
//  RRSpring
//
//  Created by jiachengwen on 12-2-21.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCBlocks.h"

@interface RCBaseRequest : MKNetworkEngine
{
    MKNetworkOperation* _operation;
    NSMutableDictionary* _fields;
    NSString* _secretKey;
}

/**
 * 执行当前请求的操作
 */
@property (nonatomic, readonly) MKNetworkOperation* operation;

/**
 * 请求参数
 */
@property (nonatomic, retain) NSMutableDictionary* fields;

/**
 * 请求参数
 */
@property (nonatomic, copy) NSString* secretKey;

/**
 * 请求完成回调
 */
@property (nonatomic, copy) onCompletionBlock onCompletion;

/**
 * 错误回调
 */
@property (nonatomic, copy) onErrorBlock onError;

/**
 * 发送请求
 */
-(void)sendQuery:(NSDictionary *)query withMethod:(NSString*)method;

/**
 * 取消请求
 */
-(void)cancelRequest;


-(MKNKEncodingBlock)postDataEncodingHandler;

-(MKNKResponseBlock)completionHandler;

-(MKNKErrorBlock)errorHandler;


@end
