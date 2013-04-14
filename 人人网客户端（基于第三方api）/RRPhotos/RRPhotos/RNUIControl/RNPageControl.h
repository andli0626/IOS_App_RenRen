//
//  RNPageControl.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-28.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNView.h"
@protocol RNPageControlDelegate;

@interface RNPageControl : RNView 
{
@private
    NSInteger _currentPage;
    NSInteger _numberOfPages;
    UIColor *dotColorCurrentPage;
    UIColor *dotColorOtherPage;
    NSObject<RNPageControlDelegate> *delegate;
}


/**
 currentPage:设置当前的page
 numberOfPages:设置总的pages
 */
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger numberOfPages;

/**
 dotColorCurrentPage:设置当前点的颜色
 dotColorOtherPage:设置其他点的颜色
 */
@property (nonatomic, retain) UIColor *dotColorCurrentPage;
@property (nonatomic, retain) UIColor *dotColorOtherPage;

/**
 delegate:代理，可选的。
 当user设置的时候，点击小点的时候，会产生回调
 */
@property (nonatomic, assign) NSObject<RNPageControlDelegate> *delegate;

@end

@protocol RNPageControlDelegate<NSObject>
@optional
- (void)pageControlPageDidChange:(RNPageControl *)pageControl;
@end