//
//  RNNewsFeedCell.m
//  RRPhotos
//
//  Created by yi chen on 12-3-27.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNNewsFeedCell.h"
#import "RNCommentListCell.h"
#import <QuartzCore/QuartzCore.h>

#define  kCellLeftPadding 2        // 内容左填充
#define  kCellTopPadding  20        //  内容顶部填充
#define  kCellBottomPadding 5       //  内容底部填充
#define  kCellRightPadding 5        //  内容右填充

#define  kCellContentViewPhotoCount  3 //滚动视图内的照片数量
#define  kCellWidth  320

//多图片滚动视图高度
#define  kCellContentViewHeight (kCellWidth / kCellContentViewPhotoCount)
#define  kCellContentViewWidth  300

//评论列表的高度
#define  kCellCommentTableViewHeight 100



@interface RNNewsFeedCell(/*私有方法*/)

@end

@implementation RNNewsFeedCell

@synthesize newsFeedItem = _newsFeedItem;
@synthesize attachmentsTableView = _attachmentsTableView;
@synthesize attachScrollView = _attachScrollView;
@synthesize commentTableView = _commentsTableView;
@synthesize delegate = _delegate;
- (void)dealloc{
	self.newsFeedItem = nil;
	self.attachmentsTableView = nil;
	self.attachScrollView = nil;
	self.commentTableView = nil;
	self.delegate = nil;
	
	[super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		

    }
    return self;
}

- (void)layoutSubviews{
	
	[super layoutSubviews];

		
	self.detailTextLabel.backgroundColor = [UIColor clearColor];
	self.textLabel.backgroundColor = [UIColor clearColor];
	self.selectionStyle = UITableViewCellSelectionStyleNone; 
	self.backgroundColor = [UIColor clearColor];

    self.accessoryType = UITableViewCellAccessoryNone;
	
	self.commentTableView.top = self.attachScrollView.bottom + 5;
	
	//计算总的cell高度
	CGFloat height = 0;
	
	if (0 != [self.newsFeedItem.commentListArray count]) {
		//存在评论列表
		height = self.commentTableView.bottom;

	}else {
		height = self.attachScrollView.bottom;
	}
	height += 20;
	self.height = height;
}

/*
	设置cell的数据
 */
- (void)setCellWithItem :(RRNewsFeedItem*)newsFeedItem{
	if (!newsFeedItem) {
		return;
	}
	
	//新鲜事主题的数据结构存储
	self.newsFeedItem = newsFeedItem;

	[self.contentView removeAllSubviews];

	[self.contentView addSubview:self.attachScrollView];
	
	
	if (self.newsFeedItem.attachments) {
		//重置滚动试图里面的照片
		if ([self.newsFeedItem.attachments count] < 3) {
			self.attachScrollView.height = 320;
		}else {
			self.attachScrollView.height = kCellContentViewHeight;
		}
		[self.attachScrollView setWithAttachments:self.newsFeedItem.attachments];
	}
	
	if ([self.newsFeedItem.commentListArray count] != 0) {
		NSLog(@"评论数为%d",[self.newsFeedItem.commentListArray count] );
		//评论列表
		[self.contentView addSubview:self.commentTableView];
		[self.commentTableView reloadData];
	}
	
	[self layoutIfNeeded];
}

/*
	附件照片滚动视图
 */
- (RRAttachScrollView *)attachScrollView{
		
	if (!_attachScrollView) {
		_attachScrollView = [[RRAttachScrollView alloc]initWithFrame:CGRectMake(10, 
																				kCellTopPadding ,
																				kCellContentViewWidth, 
																				kCellContentViewHeight)];
		_attachScrollView.attachScrollViewDelgate  = self;
	}
	return _attachScrollView;
}

- (UITableView *)commentTableView{
	if (!_commentsTableView) {
		
		_commentsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 
																		 0, 
																		 PHONE_SCREEN_SIZE.width, 
																		 80) 
														 style:UITableViewStylePlain];
		_commentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_commentsTableView.backgroundColor = [UIColor clearColor];
		_commentsTableView.delegate = self;
		_commentsTableView.dataSource = self;
	}
	return _commentsTableView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	
	return 1;
}// Default is 1 if not implemented

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSLog(@"indexPath %@",indexPath);
	return [self tableView:self.commentTableView cellForRowAtIndexPath:indexPath].height;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	NSInteger numberOfRows = [self.newsFeedItem.commentListArray count] ;
	//最多显示两行评论
	numberOfRows =  numberOfRows > 2 ? 2 : numberOfRows ;
	NSLog(@"评论数目为%d",numberOfRows);

	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSLog(@"indexpath = %@",indexPath);
	static NSString *cellIdentifier = @"commentListIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[[RNCommentListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier]autorelease];
	}
	
	[((RNCommentListCell *)cell) setCellWithItem:[self.newsFeedItem.commentListArray objectAtIndex:indexPath.row]];

	return cell;
}

#pragma mark - RRAttachScrollViewDelegate
/**
 * 点击附件照片
 */
- (void)tapAttachImageAtIndex:(NSInteger)index andAttachItem:(RRAttachmentItem *)item{
	
	NSNumber *mediaId = item.mediaId;
	NSNumber *userId = item.ownerId;
	if (self.delegate && [self.delegate respondsToSelector:@selector(onTapAttachView:photoId:)]) {
		[self.delegate onTapAttachView:userId photoId:mediaId];
	}
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////




