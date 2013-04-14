//
//  RNEmotionContentView.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-28.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNEmotionLayoutData.h"
#import "RNPageControl.h"
#import "RNView.h"
@interface RNEmotionContentView : RNView<UIScrollViewDelegate>{
    // 展示表情的scrollView
    UIScrollView *_scrollView;
    // 显示当前页数
    RNPageControl *_pageControl;
    // 上层的View
    UIView *_parentView;
    // 用于表情和表情上面的button布局的数据
    RNEmotionLayoutData *_emotionLayoutData;
    // scrollView的页数，根据emotionLayoutData里面的数据计算得到
    NSUInteger _numberOfPages;
    // 表情信息数据
    NSArray *_dataSource;
}
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) RNPageControl *pageControl;
@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) RNEmotionLayoutData *emotionLayoutData;
@property (nonatomic, retain) NSArray *dataSource;

- (id)initWithLayoutData:(RNEmotionLayoutData *) layoutData andDataSource:(NSArray *)dataSource;

@end
