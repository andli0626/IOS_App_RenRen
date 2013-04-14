//
//  RNCoustomNavBarViewController.h
//  RRSpring
//  自定义navigtionBar，给不想写navBar的同学偷懒用的，：（
//  Created by hai zhang on 2/22/12.
//  Copyright (c) 2012 Renn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNBaseViewController.h"
#import "RNNavigationBar.h"
//#import "RNNavigationExtendViewController.h"

/*
 * 导航viewController基类
 */
@interface RNNavigationViewController : RNBaseViewController <RNNavigationBarDelegate>{
    // 导航条
    RNNavigationBar *_navBar;
    // 导航扩展viewControler
//    RNNavigationExtendViewController *_extendViewController;
    // 列表扩展项
    NSMutableArray *_extendItems;
    // 当前选中扩展项索引
    NSUInteger _currentExtendItemIndex;
}

/*
 * 导航条
 */
@property (nonatomic, retain) RNNavigationBar *navBar;

/*
 * 导航扩展viewController
 */
//@property (nonatomic, retain) RNNavigationExtendViewController *extendViewController;

/*
 * 列表扩展项
 */
@property (nonatomic, retain) NSMutableArray *extendItems;

/*
 * 设置navBar的显示或隐藏
 * 
 * @hidden 是否隐藏
 * @animated 是否有动画
 */
- (void)setNavBarHidden:(BOOL)hidden animated:(BOOL)animated;

/*
 * 设置extendViewController的显示和隐藏
 * 
 * @hidden 是否隐藏
 * @animated 是否有动画
 */
- (void)setExtendViewControllerHidden:(BOOL)hidden animated:(BOOL)animated;

@end
