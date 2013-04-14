//
//  RNHotShareContentViewController.h
//  RRPhotos
//
//  Created by yi chen on 12-5-14.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNHotShareItem.h"
#import "RNMiniPublisherView.h"
#import "UIImageView+RRWebImage.h"
/*	-----------------------------------  */
/*	      热门分享内容页（含评论列表，回复框）  */
/*	-----------------------------------  */
@interface RNHotShareContentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate >
{
	//热门分享的数据项
	RNHotShareItem *_hotShareItem;
	//分享的相册缩略图
	UIImageView *_albumIconView;
	//总的内容列表
	UITableView *_contentTableView;
	//评论列表
	UITableView *_commentTableView;
	//迷你回复框
	RNMiniPublisherView *_miniPublisherView;
}
@property(nonatomic,retain)RNHotShareItem *hotShareItem;
@property(nonatomic,retain)UIImageView *albumIconView;
@property(nonatomic,retain)UITableView *contentTableView;
@property(nonatomic,retain)UITableView *commentTableView;
@property(nonatomic,retain)RNMiniPublisherView *miniPublisherView;
/*
	通过分享数据项初始化
 */
- (id)initWithHotShareItem:(RNHotShareItem *)item;
@end
