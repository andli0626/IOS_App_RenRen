//
//  RNAlbumListViewController.h
//  RRSpring
//
//  Created by sheng siglea on 4/11/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMainUser.h"
#import "RNAlbumWaterViewController.h"
#import "TestViewController.h"

@interface RNAlbumListViewController : RNBaseViewController<UITableViewDelegate,
                                        UITableViewDataSource>{
    
    UITableView *_tableView;
    NSMutableArray *_arrAlbums;
}

@end
