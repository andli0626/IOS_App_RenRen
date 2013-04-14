//
//  RNNavBar.h
//  RRSpring
//
//  Created by hai zhang on 2/20/12.
//  Copyright (c) 2012 Renn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNView.h"
@protocol RNNavigationBarDelegate;

/**
 * 右侧导航viewController的导航条
 */
@interface RNNavigationBar : RNView <UIGestureRecognizerDelegate>{
    // 背景
    UIImageView *_backgroundView;
    // 返回按钮
    UIButton *_backButton;
    // 右侧按钮
    UIButton *_rightButton;
    // 标题
    NSString *_title;
    // 标题Label
    UILabel *_titleLabel;
    // 展开标记
    UIImageView *_expandView;
    // 是否展开
    BOOL _isExpand;
    // 右侧按钮
    NSMutableArray *_extendButtons;
    // 最大扩展按钮数
    NSUInteger _maxExtendButtonCount;
    // 导航条代理
    id<RNNavigationBarDelegate> _barDelegate;
}

/*
 * 背景
 */
@property (nonatomic, retain) UIImageView *backgroundView;

/*
 * 返回按钮
 */
@property (nonatomic, readonly) UIButton *backButton;

/*
 * 右侧按钮，右侧按钮和右侧扩展按钮二选一
 */
@property (nonatomic, retain) UIButton *rightButton;

/*
 * 标题
 */
@property (nonatomic, copy) NSString *title;

/*
 * 标题Label
 */
@property (nonatomic, retain) UILabel *titleLabel;

/*
 * 展开标识
 */
@property (nonatomic, retain) UIImageView *expandView;

/*
 * 是否处于展开状态
 */
@property (nonatomic, assign) BOOL isExpand;

/*
 * 右侧扩展按钮
 */
@property (nonatomic, retain) NSMutableArray *extendButtons;

/*
 * 导航条高度
 */
@property (nonatomic, readonly) CGFloat barHeight;

/*
 * 返回按钮是否可用，NO会隐藏返回按钮，默认为YES
 */
@property (nonatomic, assign) BOOL backButtonEnable;

/*
 * 是否有扩展标识，默认为NO
 */
@property (nonatomic, assign) BOOL expandEnable;

/*
 * 右侧按钮是否可用，NO会隐藏右侧按钮，YES会隐藏扩展按钮们，默认为NO
 */
@property (nonatomic, assign) BOOL rightButtonEnable;

/*
 * 导航条代理
 */
@property (nonatomic, assign) id<RNNavigationBarDelegate> barDelegate;


/*
 * 添加一个扩展按钮
 * 
 * @target 按钮执行目标
 * @touchUpInSideSelector 在按钮上抬起时的执行方法
 * @normalImage 按钮普通图标
 * @highlightedImage 按钮高亮图标
 *
 * @return 是否添加按钮成功
 */
- (BOOL)addExtendButtonWithTarget:(id)target 
            touchUpInSideSelector:(SEL)selector
                      normalImage:(UIImage *)normalImage
                 highlightedImage:(UIImage *)highlightedImage;

/*
 * 添加一组扩展按钮
 * 
 * @buttons 添加按钮对象数组
 * 
 * @return 是否添加成功
 */
- (BOOL)addExtendButtons:(NSArray *)buttons;

/*
 * 添加一个扩展按钮
 *
 * @button 添加的按钮对象
 *
 * @return 是否添加按钮成功，失败的原因可能是因为按钮数超过最大允许数量（默认3）
 */
- (BOOL)addExtendButton:(UIButton *)button;

/*
 * 清空所有扩展按钮
 */
- (void)cleanExtendButtons;


@end

/*
 * 导航条代理
 */
@protocol RNNavigationBarDelegate <NSObject>

/*
 * 点击扩展按钮
 * 
 * @expand 是否打开扩展
 */
- (void)navigationBar:(RNNavigationBar *)navigationBar didClickExpand:(BOOL)expand;

@end

