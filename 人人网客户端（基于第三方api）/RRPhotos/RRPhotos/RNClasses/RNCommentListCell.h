//
//  RNCommentListCell.h
//  RRPhotos
//
//  Created by yi chen on 12-5-13.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRNewsFeedItem.h"
#import "UIImageView+RRWebImage.h"
/*	-------------------------------------	*/
/*			评论列表的cell					*/
/*	-------------------------------------	*/
@interface RNCommentListCell : UITableViewCell
{
	//头像
	UIImageView *_headImageView;
	//评论内容
	UILabel *_contentLabel;
	//评论时间
	UILabel *_updateTimeLabel;
	//用户名
	UILabel *_userNameLabel;
	
	//cell数据
	RRNewsFeedCommentItem *_newsFeedCommentItem;
}
@property(nonatomic,retain)UIImageView *headImageView;
@property(nonatomic,retain)UILabel *contentLabel;
@property(nonatomic,retain)UILabel *updateTimeLabel;
@property(nonatomic,retain)UILabel *userNameLabel;
@property(nonatomic,retain)RRNewsFeedCommentItem *newsFeedCommentItem;

/*
	设置cell的数据
 */
- (void)setCellWithItem :(RRNewsFeedCommentItem*)commentItem;
@end
