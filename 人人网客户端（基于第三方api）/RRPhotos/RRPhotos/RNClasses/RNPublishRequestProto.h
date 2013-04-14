//
//  RNPublishRequestProto.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-12.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//用于本地客户端publish发送数据的时候回传给html实现数据实时华的

#import <Foundation/Foundation.h>

@protocol RNPublishRequestProto <NSObject>
@optional
-(void)publishRequestData:(NSMutableDictionary*)requestdata;

@end