//
//  RNNewsFeedSectionView.h
//  RRPhotos
//
//  Created by yi chen on 12-5-15.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNView.h"
#import "RRNewsFeedItem.h"
#import "UIImageView+RRWebImage.h"

@protocol RNNewsFeedSectionViewDelegate <NSObject>

@optional

/*
 点击新鲜事标题,即相册名称
 
 */
- (void)onTapTitleLabel: (NSNumber *)userId albumId: (NSNumber *)photoId ;

/*
	点击头像
 */
- (void)onTapHeadImageView:(NSNumber *)userId;
/*
 */
- (void)onTapHeadImageView:(NSNumber *)userId userName:(NSString *)userName;
@end

@interface RNNewsFeedSectionView : RNView
{
	//新鲜事主体数据
	RRNewsFeedItem *_newsFeedItem;
	//头像图片
	UIImageView *_headImageView;
	//好友姓名
	UILabel* _userNameLabel;
	//新鲜事内容前缀
	UILabel	*_prefixLabel;
	//新鲜事主体内容
	UILabel *_titleLabel;
	//新鲜事时间
	UILabel *_updateTimeLabel;

	id<RNNewsFeedSectionViewDelegate>_delegate;
}
@property(nonatomic, retain)RRNewsFeedItem *newsFeedItem;	
@property(nonatomic, retain)UIImageView *headImageView;
@property(nonatomic, retain)UILabel *userNameLabel;
@property(nonatomic, retain)UILabel *prefixLabel;
@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, retain)UILabel *updateTimeLabel;
@property(nonatomic, assign)id<RNNewsFeedSectionViewDelegate>delegate;

/*
	@newsFeedItem :新鲜事数据
 */
- (id)initWithItem :(RRNewsFeedItem*)newsFeedItem;
@end
