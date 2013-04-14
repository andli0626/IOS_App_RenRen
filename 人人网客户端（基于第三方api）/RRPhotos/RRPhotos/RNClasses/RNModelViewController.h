//
//  RNModelViewController.h
//  RRSpring
//
//  Created by hai zhang on 3/6/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//       

#import <Foundation/Foundation.h>
#import "RNBaseViewController.h"
#import "RNModel.h"
#import "RNNavigationViewController.h"

@interface RNModelViewController : RNNavigationViewController {
    RNModel *_model;
}

// 创建Model，子类必须实现
- (void)createModel;
// 加载数据
- (void)load:(BOOL)more;

@property (nonatomic, retain) RNModel *model;

@end
