//
//  RNCommentListCell.m
//  RRPhotos
//
//  Created by yi chen on 12-5-13.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNCommentListCell.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kCellHeight = 40;
static const CGFloat kCellWidth = 320;
static const CGFloat kCellPaddingLeft = 10.0;
static const CGFloat kCellPaddingTop = 5;
static const CGFloat kCellHeadImageWidth = 30;
static const CGFloat kCellHeadImageHeight = 30;
static const CGFloat kCellSpace = 10; //头像与评论内容的空隙

static const CGFloat kCellContentLabelWidth = 320 - kCellSpace - kCellPaddingLeft - kCellHeadImageWidth ;
static const CGFloat kCellContentLabelHeight = 15;

@implementation RNCommentListCell
@synthesize headImageView = _headImageView;
@synthesize contentLabel = _contentLabel;
@synthesize updateTimeLabel = _updateTimeLabel;
@synthesize userNameLabel = _userNameLabel;
@synthesize newsFeedCommentItem = _newsFeedCommentItem;

- (void)dealloc{
	self.headImageView = nil;
	self.contentLabel  = nil;
	self.updateTimeLabel = nil;
	self.userNameLabel = nil;
	self.newsFeedCommentItem = nil;

	[super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
	设置cell的数据
 */
- (void)setCellWithItem :(RRNewsFeedCommentItem*)commentItem{
	if (!commentItem) {
		return;
	}
	[self.contentView removeAllSubviews];
	
	self.newsFeedCommentItem = commentItem;
	if (commentItem.headUrl) {
		NSURL *url = [NSURL URLWithString:commentItem.headUrl];
		[self.headImageView setImageWithURL:url];
	}
	if (commentItem.content) {
		self.contentLabel.text = commentItem.content;
	}
	if (commentItem.time) {
		// 时间格式MM-dd HH:mm
		self.updateTimeLabel.text = [commentItem.time stringForTimeline];
	}
	if (commentItem.userName) {
		self.userNameLabel.text = commentItem.userName;
	}
	[self.contentView addSubview:self.headImageView];
	[self.contentView addSubview:self.contentLabel];
	[self.contentView addSubview:self.userNameLabel];
	[self.contentView addSubview:self.updateTimeLabel];
	[self layoutIfNeeded];
}

- (void)layoutSubviews{
	[super layoutSubviews];

	self.height = kCellHeight;
	
	self.detailTextLabel.backgroundColor = [UIColor clearColor];
	self.textLabel.backgroundColor = [UIColor clearColor];
	self.selectionStyle = UITableViewCellSelectionStyleNone; 
	self.backgroundColor = [UIColor clearColor];
    self.accessoryType = UITableViewCellAccessoryNone;
}
/*
	头像的view
 */
- (UIImageView *)headImageView{
	if (!_headImageView) {
		_headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kCellPaddingLeft,
																	  kCellPaddingTop,
																	  kCellHeadImageWidth, 
																	  kCellHeadImageHeight)];
		CALayer* layer = [_headImageView layer];
		[layer setCornerRadius:4];
		layer.masksToBounds = YES;
		
		//点击头像，进入某个用户的主页
		_headImageView.userInteractionEnabled = YES;
		[_headImageView addTargetForTouch:self action:@selector(onTapHeadImageView:)];
	}
	return _headImageView;
}

/*
	评论内容
 */
- (UILabel *)contentLabel{
	
	if (!_contentLabel) {
		_contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(kCellPaddingLeft + kCellHeadImageWidth + kCellSpace,
																self.userNameLabel.bottom + 5, 
																kCellContentLabelWidth, 
																kCellContentLabelHeight)];
		_contentLabel.backgroundColor = [UIColor clearColor];
		_contentLabel.textColor = [UIColor blackColor];
		_contentLabel.font = [UIFont systemFontOfSize:12];
	}
	return _contentLabel ;
}
/*
	评论时间
 */
- (UILabel *)updateTimeLabel{
	if (!_updateTimeLabel) {
		_updateTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kCellWidth - 60,
																   kCellPaddingTop,
																   60, 
																   kCellContentLabelHeight)];
		_updateTimeLabel.textColor = RGBCOLOR(100, 100,100);
		_updateTimeLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:10];
		_updateTimeLabel.backgroundColor = [UIColor clearColor];

	}
	return _updateTimeLabel;
}

/*
	用户名
 */
- (UILabel *)userNameLabel{
	if (!_userNameLabel) {
		_userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(kCellPaddingLeft + kCellHeadImageWidth + kCellSpace,
																 kCellPaddingTop,
																 200,
																 kCellContentLabelHeight)];
		_userNameLabel.backgroundColor = [UIColor clearColor];
		_userNameLabel.textColor = RGBCOLOR(0, 229 ,238);
		_userNameLabel.font = [UIFont systemFontOfSize:13];
		
	}
	return  _userNameLabel;
}
/*
	点击头像
 */
- (void)onTapHeadImageView:(id)sender{
	
}
@end
