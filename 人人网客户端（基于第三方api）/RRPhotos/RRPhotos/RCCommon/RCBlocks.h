//
//  RCBlocks.h
//  RRSpring
//
//  Created by renren-inc on 12-2-16.
//  Copyright (c) 2012年 Renn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^onProgressBlock)(double progress);
typedef void (^onCompletionBlock)(id result);
typedef void (^onErrorBlock) (RCError* error);