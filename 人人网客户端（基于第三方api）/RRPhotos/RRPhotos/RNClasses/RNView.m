//
//  RNView.m
//  RRSpring
//
//  Created by 洪杰 任 on 12-4-16.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNView.h"

@implementation RNView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)changeSkinAction:(id)sender {
    // 第一步：重置需要手动更新的素材
    // 第二步：重新显示 [RSView setNeedLayout] && [RSViewController viewWillApear]
    // 第三部：回调通知一下完成程度
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
