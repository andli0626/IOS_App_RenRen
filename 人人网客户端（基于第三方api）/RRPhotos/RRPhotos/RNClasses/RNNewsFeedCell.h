//
//  RNNewsFeedCell.h
//  RRPhotos
//
//  Created by yi chen on 12-3-27.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRImageView.h"
#import "RRAttachScrollView.h"
#import "RRNewsFeedItem.h"
#import "UIImageView+RRWebImage.h"

@protocol RNNewsFeedCellDelegate <NSObject>

@optional

/*
	点击新鲜事附件照片
 */
- (void)onTapAttachView:(NSNumber *)userId photoId:(NSNumber *)photoId;

@end

/*	-------------------------------------	*/
/*			新鲜事主列表的cell					*/
/*	-------------------------------------	*/
@interface RNNewsFeedCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate,RRAttachScrollViewDelegate>
{
	//新鲜事主体数据
	RRNewsFeedItem *_newsFeedItem;
	
	//附件照片
	UITableView	*_attachmentsTableView;
	//附件照片滚动视图
	RRAttachScrollView *_attachScrollView;
	//评论列表
	UITableView *_commentsTableView;
	
	id<RNNewsFeedCellDelegate> _delegate;
}
@property(nonatomic, retain)RRNewsFeedItem *newsFeedItem;	
@property(nonatomic, retain)UITableView	*attachmentsTableView;
@property(nonatomic, retain)RRAttachScrollView *attachScrollView;
@property(nonatomic, retain)UITableView *commentTableView;
@property(nonatomic, assign)id<RNNewsFeedCellDelegate>delegate;

/*
	设置cell的数据
 */
- (void)setCellWithItem :(RRNewsFeedItem*)newsFeedItem;

@end

////////////////////////////////////////////////////////////////////////////////////////////////

