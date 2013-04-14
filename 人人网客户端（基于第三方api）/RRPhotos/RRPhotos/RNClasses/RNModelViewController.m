//
//  RNModelViewController.m
//  RRSpring
//
//  Created by hai zhang on 3/6/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNModelViewController.h"


@implementation RNModelViewController
@synthesize model = _model;

- (void)dealloc {
    [_model.delegates removeObject:self];
    RL_RELEASE_SAFELY(_model);
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
        [self createModel];
    }
    
    return self;
}


// 加载数据
- (void)load:(BOOL)more {
    [_model load:more];
}

// 创建Model，子类必须实现
- (void)createModel {
    //子类实现
}

// 重写set方法
- (void)setModel:(RNModel *)model {
    if (_model == model) {
        return;
    }
    
    if (_model != nil) {
        [_model.delegates removeObject:self];
        RL_RELEASE_SAFELY(_model);
    }
    
    _model = [model retain];
    [_model.delegates addObject:self];
}

#pragma mark - RNModelDelegate
// 开始
- (void)modelDidStartLoad:(RNModel *)model {
    // 子类实现
}

// 完成
- (void)modelDidFinishLoad:(RNModel *)model {
    // 子类实现
}

// 错误处理
- (void)model:(RNModel *)model didFailLoadWithError:(RCError *)error {
    // 子类实现
}

// 取消
- (void)modelDidCancelLoad:(RNModel *)model {
    // 子类实现
}

@end
