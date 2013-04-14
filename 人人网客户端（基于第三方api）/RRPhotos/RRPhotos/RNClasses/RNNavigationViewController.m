//
//  RNCoustomNavBarViewController.m
//  RRSpring
//
//  Created by hai zhang on 2/22/12.
//  Copyright (c) 2012 Renn. All rights reserved.
//

#import "RNNavigationViewController.h"

@implementation RNNavigationViewController

@synthesize navBar = _navBar;
//@synthesize extendViewController = _extendViewController;
@synthesize extendItems = _extendItems;

- (void)dealloc {
    self.navBar = nil;
//    self.extendViewController = nil;
    self.extendItems = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        RNNavigationBar *navBar = [[RNNavigationBar alloc] initWithFrame:CGRectMake(0, 
                                                                                    0,
                                                                                    PHONE_SCREEN_SIZE.width,
                                                                                    CONTENT_NAVIGATIONBAR_HEIGHT)];
        navBar.barDelegate = self;
        self.navBar = navBar;
        RL_RELEASE_SAFELY(navBar);
        
//        RNNavigationExtendViewController *extendViewController = [[RNNavigationExtendViewController alloc] init];
//        extendViewController.view.frame = CGRectMake(0,
//                                                     -PHONE_SCREEN_SIZE.height,
//                                                     PHONE_SCREEN_SIZE.width,
//                                                     PHONE_SCREEN_SIZE.height - CONTENT_NAVIGATIONBAR_HEIGHT);
//        extendViewController.extendDataSource = self;
//        extendViewController.extendDelegate = self;
//        self.extendViewController = extendViewController;
//        RL_RELEASE_SAFELY(extendViewController);
    }
    
    return self;
}

- (void)loadView {
    [super loadView];

//    [self.view addSubview:self.extendViewController.view];
    [self.view addSubview:self.navBar];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
//    [self.view bringSubviewToFront:self.extendViewController.view];
    [self.view bringSubviewToFront:self.navBar];
}

/*
 * 设置navBar的显示或隐藏
 * 
 * @hidden 是否隐藏
 * @animated 是否有动画
 */
- (void)setNavBarHidden:(BOOL)hidden animated:(BOOL)animated{
    if (animated) {
        [UIView animateWithDuration:NAVIGATIONBAT_ANIMATION_TIMEINTERVAL
                         animations:^{
                             self.navBar.frame = CGRectMake(0,
                                                            hidden ? -CONTENT_NAVIGATIONBAR_HEIGHT : 0,
                                                            PHONE_SCREEN_SIZE.width,
                                                            CONTENT_NAVIGATIONBAR_HEIGHT);
                         }
                         completion:^(BOOL finished){
                             //self.navBar.hidden = hidden;
                         }];
    }
    else{
        self.navBar.hidden = hidden;
   }
}

/*
 * 设置extendViewController的显示和隐藏
 * 
 * @hidden 是否隐藏
 * @animated 是否有动画
 */
- (void)setExtendViewControllerHidden:(BOOL)hidden animated:(BOOL)animated{
    if (animated) {
        [UIView animateWithDuration:NAVIGATION_EXTEND_ANIMATION_TIMEINTEVAL
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
//                             self.extendViewController.view.frame = CGRectMake(0,
//                                                            hidden ? -PHONE_SCREEN_SIZE.height : CONTENT_NAVIGATIONBAR_HEIGHT,
//                                                            PHONE_SCREEN_SIZE.width,
//                                                            PHONE_SCREEN_SIZE.height - CONTENT_NAVIGATIONBAR_HEIGHT);
                         }
                         completion:^(BOOL finished){
                             //NSLog(@"subsView %@", self.view.subviews);
                             //[self.view bringSubviewToFront:self.extendViewController.view];
                         }];
    }
    else{
        self.navBar.hidden = hidden;
    }
}


/*
 * 重写setTitle方法，给navBar的title赋值
 */
- (void)setTitle:(NSString *)title{
    [super setTitle:title];
    
    self.navBar.title = title;
}

/*
 * 重写设置extendItems数组，用来设置bar的展开标记是否显示
 */
- (void)setExtendItems:(NSMutableArray *)extendItems{
    _extendItems = [extendItems retain];
    
    if (_extendItems == nil || _extendItems.count == 0) {
        self.navBar.expandEnable = NO;
    }
    else{
        self.navBar.expandEnable = YES;
    }
    //如果子类中在设置_extendItems之前去设置navBar的样式的时候，系统会先调用view的加载，
//    [self.extendViewController.tableView reloadData];
}

#pragma mark - navigationBar Delegate
- (void)navigationBar:(RNNavigationBar *)navigationBar didClickExpand:(BOOL)expand{
    [self setExtendViewControllerHidden:!expand animated:YES];
}

#pragma mark - extendViewController Delegate
//- (NSInteger)numberOfExtendItems:(RNNavigationExtendViewController *)extendViewController{
//    if (self.extendItems == nil) {
//        return 0;
//    }
//    
//    return self.extendItems.count;
//}
//
//- (RNNavigationExtendItem *)navigationExtendViewController:(RNNavigationExtendViewController *)extendViewController 
//                                          itemForIndex:(NSUInteger)index{
//    if (self.extendItems == nil || index >= self.extendItems.count) {
//        return nil;
//    }
//    
//    return [self.extendItems objectAtIndex:index];
//}
//
//- (void)navigationExtendViewController:(RNNavigationExtendViewController *)extendViewController 
//                       willSelectIndex:(NSUInteger)index{
//    if (self.extendItems == nil || index >= self.extendItems.count) {
//        return;
//    }
//    
//    _currentExtendItemIndex = index;
//}
//
//- (void)navigationExtendViewController:(RNNavigationExtendViewController *)extendViewController 
//                        didSelectIndex:(NSUInteger)index{
//    if (self.extendItems == nil || index >= self.extendItems.count) {
//        return;
//    }
//    
//    RNNavigationExtendItem *item = [self.extendItems objectAtIndex:index];
//    
//    self.title = item.title;
//    self.navBar.isExpand = NO;
//    _currentExtendItemIndex = index;
//    [self setExtendViewControllerHidden:YES animated:YES];
//}
//
//- (NSUInteger)currentSelectIndexOfExtendViewController:(RNNavigationExtendViewController *)extendViewController{
//    return _currentExtendItemIndex;
//}
//
///*
// * pullBlock开始移动
// */
//- (void)navigationExtendViewController:(RNNavigationExtendViewController *)extendViewController 
//                  beginMoveTranslation:(CGFloat)translation
//                              velocity:(CGFloat)velocity{
//    self.extendViewController.view.frame = CGRectMake(0,
//                                                      CGRectGetMinY(self.extendViewController.view.frame)+translation, 
//                                                      CGRectGetWidth(self.extendViewController.view.frame), 
//                                                      CGRectGetHeight(self.extendViewController.view.frame));
//}
//
///*
// * pullBlock移动中
// */
//- (void)navigationExtendViewController:(RNNavigationExtendViewController *)extendViewController 
//                     movingTranslation:(CGFloat)translation
//                              velocity:(CGFloat)velocity{
//    self.extendViewController.view.frame = CGRectMake(0,
//                                                      CGRectGetMinY(self.extendViewController.view.frame)+translation, 
//                                                      CGRectGetWidth(self.extendViewController.view.frame), 
//                                                      CGRectGetHeight(self.extendViewController.view.frame));
//}
//
///*
// * pullBlock移动停止
// */
//- (void)navigationExtendViewController:(RNNavigationExtendViewController *)extendViewController 
//                   stopMoveTranslation:(CGFloat)translation
//                              velocity:(CGFloat)velocity{
//
//    BOOL isExpand = NO;
//    if (velocity >= 0) {
//        isExpand = YES;
//    }
//    
//    self.navBar.isExpand = isExpand;
//    
//    [self setExtendViewControllerHidden:!isExpand
//                               animated:YES];
//
//}

@end
