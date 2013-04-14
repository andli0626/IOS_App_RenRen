//
//  RCPreLocate.h
//  RRSpring
//
//  Created by  on 12-4-12.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCBaseRequest.h"

// 关心返回结果的，需要实现这个block
typedef void (^preLocateFinished)(NSMutableDictionary* result);
typedef void (^preLocateFailed)(RCError* error);

@interface RCPreLocate : RCBaseRequest{
    NSNumber* _longitude;
    NSNumber* _latitude;
    preLocateFinished _onPreLocateFinished;
    preLocateFailed _onPrelocateFailed;
}
@property (nonatomic, retain)NSNumber* longitude;
@property (nonatomic, retain)NSNumber* latitude;
//接口用户必须实现这个block
@property (nonatomic, copy) preLocateFinished onPreLocateFinished;
@property (nonatomic, copy) preLocateFailed onPrelocateFailed;

- (void)sendRequest;

@end
