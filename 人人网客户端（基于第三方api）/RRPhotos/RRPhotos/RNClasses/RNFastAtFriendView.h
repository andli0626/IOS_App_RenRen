//
//  RNFastAtFriendView.h
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-26.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 * 导航条代理
 */
@protocol RNFastAtFriendViewDelegate <NSObject>
/*
 * 点击选中某个人
 *pram： 回传一个字符串格式为：@名字(id)
 */
-(void)didSelectUser:(NSString*)atuserinfo;

@end


@interface RNFastAtFriendView : UIView<UITableViewDelegate, UITableViewDataSource>{
    UITableView *_tableView;
    //选择的数据存放变量
    NSMutableArray *_friendData;
    //搜索的当前数据
    NSMutableArray *_searchData;
    //
    UIView *_parentview;
    id<RNFastAtFriendViewDelegate> _deldgate;
}
@property (nonatomic, assign) id<RNFastAtFriendViewDelegate> deldgate;
@property (nonatomic ,assign) UIView *parentview;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *friendData;
//搜索的数据
@property (nonatomic,retain)  NSMutableArray *searchData;

-(RNFastAtFriendView*)initWithParent:(CGRect)frame parent:(UIView*)parentview;

-(BOOL)showFastAtFriendView:(CGPoint)point searchText:(NSString*)searchtext;
-(void)hideFastAtFriendView;
@end
