//
//  RNNewsFeedSectionView.m
//  RRPhotos
//
//  Created by yi chen on 12-5-15.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RNNewsFeedSectionView.h"
#import <QuartzCore/QuartzCore.h>

#define  kPaddingLeft 5       // 内容左填充
#define  kPaddingTop  2        //  内容顶部填充
#define  kPaddingBottom 5       //  内容底部填充
#define  kPaddingRight  5        //  内容右填充

#define  kHeadImageHeight 40    // 头像高度
#define  kHeadImageWidth 40		// 头像宽度 

#define  kWidth   320
#define  kHeight  kNewsFeedSectionViewHeight
/*	
	私有方法
 */
@interface RNNewsFeedSectionView()

// 配置数据
- (void)configData;
@end

@implementation RNNewsFeedSectionView

@synthesize newsFeedItem = _newsFeedItem;
@synthesize headImageView = _headImageView;
@synthesize userNameLabel = _userNameLabel;
@synthesize prefixLabel = _prefixLabel;
@synthesize titleLabel = _titleLabel;
@synthesize updateTimeLabel = _updateTimeLabel;
@synthesize delegate = _delegate;
- (void)dealloc{
	self.newsFeedItem = nil;
	self.headImageView = nil;
	self.userNameLabel = nil;
	self.prefixLabel = nil;
	self.titleLabel = nil;
	self.updateTimeLabel = nil;
	self.delegate = nil;
	
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
} 

/*
 @newsFeedItem :新鲜事数据
 */
- (id)initWithItem :(RRNewsFeedItem*)newsFeedItem{
	if (self = [super initWithFrame:CGRectMake(0, 0, kWidth, kHeight)]) {
		if (newsFeedItem) {
			self.newsFeedItem = newsFeedItem;
			[self configData];
			
			[self addSubview:self.headImageView];
			[self addSubview:self.userNameLabel];
			[self addSubview:self.prefixLabel];
			[self addSubview:self.updateTimeLabel];
			[self addSubview:self.titleLabel];
		}
	}
	return self;
}
/*
	设置相关数据
 */
- (void)configData{
	/////配置数据
	if (self.newsFeedItem.headUrl) {
		NSURL *url = [NSURL URLWithString:self.newsFeedItem.headUrl];
		[self.headImageView setImageWithURL:url];
	}
	//头像
	if (self.newsFeedItem.headUrl) {
		[self.headImageView setImageWithURL:[NSURL URLWithString:self.newsFeedItem.headUrl]
						   placeholderImage:[UIImage imageNamed:@"main_head_profile.png"]];
	}
	
	//用户名
	if (self.newsFeedItem.userName ) {
		self.userNameLabel.text = self.newsFeedItem.userName;
	}
	
	if (self.newsFeedItem.prefix) {
		NSMutableString  *prefixAndTitleString = [NSMutableString stringWithString: self.newsFeedItem.prefix];
		self.prefixLabel.text  = prefixAndTitleString;
	}
	if (self.newsFeedItem.title) {
		self.titleLabel.text = self.newsFeedItem.title;
	}
	
	if (self.newsFeedItem.updateTime) {
		self.updateTimeLabel.text = [self.newsFeedItem.updateTime stringForSectionTitle3];
	}
	
	[self layoutIfNeeded];
}
- (void)layoutSubviews{
	[super layoutSubviews];
	self.userInteractionEnabled = YES;
	self.backgroundColor = kNewsFeedSectionBgColor;
	
	//布局标题的位置
	NSString *s = self.prefixLabel.text;
	UIFont *font = self.prefixLabel.font;
	CGSize singleLineStringSize = [s sizeWithFont:font];
	self.prefixLabel.width = singleLineStringSize.width;
	self.titleLabel.left = self.prefixLabel.right;
	self.titleLabel.width = kWidth - self.prefixLabel.right ;
}
/*
	头像的view
 */
- (UIImageView *)headImageView{
	if (!_headImageView) {
		_headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kPaddingLeft,
																	  kPaddingTop,
																	  kHeadImageWidth, 
																	  kHeadImageHeight)];
		CALayer* layer = [_headImageView layer];
		[layer setCornerRadius:4.0];
		layer.masksToBounds = YES;
		
		//点击头像，进入某个用户的主页
		_headImageView.userInteractionEnabled = YES;
		[_headImageView addTargetForTouch:self action:@selector(onTapHeadImageView:)];
	}
	return _headImageView;
}

/*
	用户名标签
 */
- (UILabel *)userNameLabel{
	if (!_userNameLabel) {
		_userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60,
																  kPaddingTop,
																  200, 
																  kHeadImageHeight / 2)];
		
		_userNameLabel.backgroundColor = [UIColor clearColor];
		_userNameLabel.textColor = RGBCOLOR(0, 229 ,238);
		_userNameLabel.font = [UIFont systemFontOfSize:15];
		
		//添加点击事件，和头像点击事件一样
		_userNameLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]   
											  initWithTarget:self action:@selector(onTapHeadImageView:)]autorelease];
		[_userNameLabel addGestureRecognizer:singleTap]; 
	}
	
	return _userNameLabel;
}

/*
	新鲜事更新时间
 */
- (UILabel *)updateTimeLabel{
	if (!_updateTimeLabel) {
		_updateTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth - 60, 
																	self.userNameLabel.top,
																	60,
																	20)];
		_updateTimeLabel.textColor = RGBCOLOR(100, 100,100);
		_updateTimeLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:10];
		_updateTimeLabel.backgroundColor = [UIColor clearColor];
	}
	return _updateTimeLabel;
}

/*
 新鲜事内容前缀
 */
- (UILabel *)prefixLabel{
	if (!_prefixLabel) {
		_prefixLabel = [[UILabel alloc]initWithFrame:CGRectMake(70,
																kPaddingTop + self.userNameLabel.height,
																kWidth - kPaddingLeft - 70, 
																kHeadImageHeight / 2)];
		_prefixLabel.textColor = RGBCOLOR(100, 100, 100);
		_prefixLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:12];
		_prefixLabel.backgroundColor = [UIColor clearColor];
	}
	return _prefixLabel;
}

/*
	新鲜事主体内容
 */
- (UILabel *)titleLabel{
	
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.prefixLabel.right + 10, 
															   self.prefixLabel.origin.y, 
															   100, 
															   kHeadImageHeight / 2)];
		_titleLabel.textColor = RGBCOLOR(200, 150, 100);
		_titleLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:13];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.userInteractionEnabled = YES;
		//添加点击事件
		UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]   
											  initWithTarget:self action:@selector(onTapTitleLabel)]autorelease];
		[_titleLabel addGestureRecognizer:singleTap]; 
	}
	return _titleLabel;
}
#pragma mark - 点击事件

/*
 点击标题,将进入相册内容页面（流式布局）
 */
- (void)onTapTitleLabel{
	//暂时这样处理，日后想办法改进
	RRAttachmentItem *item = self.newsFeedItem.firstAttachment;
	NSNumber *mediaId = item.mediaId;
	NSNumber *userId = item.ownerId;
	
	if ([self.delegate respondsToSelector:@selector(onTapTitleLabel:albumId:)]) {
		[self.delegate onTapTitleLabel:userId albumId:mediaId];
	}
}

/*
 点击头像/点击用户名称
 */
- (void)onTapHeadImageView:(id) sender{
	NSNumber *userId = self.newsFeedItem.userId;
	NSString *userName = self.newsFeedItem.userName;
	if (!userId) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(onTapHeadImageView:userName:)]) {
		[self.delegate onTapHeadImageView:userId userName:userName];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"head touch begin");
	
}
@end
