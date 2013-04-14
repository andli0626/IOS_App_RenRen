//
//  RNPublishBaseViewController.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNModel.h"
#import "RNPublisherAccessoryBar.h"

@interface RNPublishBaseViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,RNPublisherAccessoryBarDelegate>{
    UITableView *_tableView;
    RNModel *_model;
    //导航条
    RNPublisherAccessoryBar *_accessoryBar;
}
// 创建Model，子类必须实现
- (void)createModel;
// 加载数据
- (void)load:(BOOL)more;

@property (nonatomic, retain) RNModel *model;

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic,retain)    RNPublisherAccessoryBar *accessoryBar;




@end
