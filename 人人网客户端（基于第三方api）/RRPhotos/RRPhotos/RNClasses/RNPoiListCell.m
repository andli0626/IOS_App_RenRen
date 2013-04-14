//
//  RNPoiListCell.m
//  RRSpring
//
//  Created by yi chen on 12-4-14.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPoiListCell.h"

//上填充
#define kPoiCellPaddingTop 9 
//左填充
#define kPoiCellPaddingLeft 11
//右填充
#define kPoiCellPaddingRigth 5
//底部填充
#define kPoiCellPaddinBottom 5
//cell宽度
#define kPoiCellWidth (PHONE_SCREEN_SIZE.width)

//图片和文字间的空隙
#define kPoiCellSpace 10

//cell背景
#define kPoiCellBgSelected @"rn_common_cell_select_bg"
#define kPoiCellBg @"rn_common_cell_bg"

//选中时的icon图片
#define kSelectIconImage @"quickReport_place_hl"
//未选中的icon图片
#define kUnSelectIconImage @"quickReport_place"
//自己曾今到访过的足迹标识
#define kFootIconImage @"quickReport_place_select"

@implementation RNPoiListCell
@synthesize isSelectIconView = _isSelectedIconView;
@synthesize bIsSelected = _bIsSelected;
@synthesize placeNameLabel = _placeNameLabel;
@synthesize reportTimesLabel = _reportTimesLabel;
@synthesize footIconView = _footIconView;

- (void)dealloc{
	self.isSelectIconView = nil;
	self.placeNameLabel = nil;
	self.reportTimesLabel = nil;
	self.footIconView = nil;
	
	[super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		UIImageView *backView = [[[UIImageView alloc]initWithImage:
								  [[RCResManager getInstance]imageForKey:kPoiCellBg ]]autorelease];
		[backView sizeToFit];
		[self setBackgroundView:backView]; //设置Cell背景图
		
		UIImageView *backViewSel = [[[UIImageView alloc]initWithImage:
									 [[RCResManager getInstance]imageForKey:kPoiCellBgSelected]]autorelease];
		[backViewSel sizeToFit];
		[self setSelectedBackgroundView:backViewSel]; //设置Cell选中的背景图片
		
    }
    return self;
}


/*
	利用poi信息重置cell显示数据
 */
- (void)setWithPoiCellInfoDic: (NSDictionary *) cellInfoDic{
	
	if (!cellInfoDic) {
		return;
	}

	//地点名称
	if([cellInfoDic objectForKey:@"poi_name"]){
		NSString *name = [NSString stringWithFormat:@"%@",[cellInfoDic objectForKey:@"poi_name"]];
		if ([name isEqual:@""]) {
			name = NSLocalizedString(@"未知地点", @"未知地点");
		}
		self.placeNameLabel.text = name;
	}
	
	//到访次数
	if ([cellInfoDic objectForKey: @"total_vistited"]) {
		NSInteger reportTimes = [[cellInfoDic objectForKey: @"total_vistited"]intValue];
		self.reportTimesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d次到访", @"%d次到访"),reportTimes];
	}
	
	//自己是否曾经报道过
	if ([cellInfoDic objectForKey:@"self_checkin"]) {
		_bSelfCheckin = [[cellInfoDic objectForKey:@"self_checkin"]boolValue];
	}
	
	[self.contentView removeAllSubviews];
	[self.contentView addSubview: self.isSelectIconView];
	[self.contentView addSubview: self.placeNameLabel];
	[self.contentView addSubview: self.reportTimesLabel];
	if (_bSelfCheckin) {
		[self.contentView addSubview: self.footIconView];
	}
}

/*
	布局子视图
 */
- (void)layoutSubviews{
	[super layoutSubviews];
	//允许用户交互?
	self.backgroundView.userInteractionEnabled = YES;
	self.userInteractionEnabled = YES;
	
	self.detailTextLabel.backgroundColor = [UIColor clearColor];
	self.textLabel.backgroundColor = [UIColor clearColor];
	self.backgroundColor = [UIColor clearColor];
	
	if (_bIsSelected) { //选中切换图片
		UIImage *selectedImage = [[RCResManager getInstance]imageForKey:kSelectIconImage];
		self.isSelectIconView.image = selectedImage;
	}else {
		UIImage *unSelectedImage = [[RCResManager getInstance]imageForKey:kUnSelectIconImage];
		self.isSelectIconView.image = unSelectedImage;
	}
	
	//
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	
	//更新选中状态
	self.bIsSelected = selected;
	[self layoutIfNeeded];
	
    // Configure the view for the selected state
}

/*
	poi选中标记的图片
 */
- (UIImageView *)isSelectIconView{
	
	if (!_isSelectedIconView) {
		UIImage *iconImage = [[RCResManager getInstance]imageForKey:kUnSelectIconImage];
		_isSelectedIconView = [[UIImageView alloc]initWithImage:iconImage];
		CGSize iconSize = _isSelectedIconView.image.size;
		_isSelectedIconView.frame = CGRectMake(kPoiCellPaddingLeft, kPoiCellPaddingTop, iconSize.width, iconSize.height);
	}
	return _isSelectedIconView;	
}

/*
	地点名字
 */
- (UILabel *)placeNameLabel {
	if (!_placeNameLabel) {
		_placeNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(38 , 
																  10,
																  kPoiCellWidth - self.isSelectIconView.width - self.footIconView.width, 
																  17)];
		_placeNameLabel.backgroundColor = [UIColor clearColor];
		_placeNameLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:15];
		_placeNameLabel.textColor = [UIColor blackColor];
	}
	
	return _placeNameLabel;
}

/*
	报道次数标签
 */
- (UILabel *)reportTimesLabel{
	if(!_reportTimesLabel){
		_reportTimesLabel = [[UILabel alloc]initWithFrame:CGRectMake(38, 
																	 self.placeNameLabel.bottom + 10, 
																	 kPoiCellWidth - self.isSelectIconView.width - self.footIconView.width, 
																	 12 )];
		_reportTimesLabel.backgroundColor = [UIColor clearColor];
		_reportTimesLabel.font = [UIFont fontWithName:MED_HEITI_FONT size:12];
		_reportTimesLabel.alpha = 0.35;
		_reportTimesLabel.textColor = [UIColor blackColor];

	}
	return _reportTimesLabel;
}
/*
	曾经报道过的足迹标志
 */
- (UIImageView *)footIconView{
	
	if (!_footIconView) {
		_footIconView = [[UIImageView alloc]initWithImage:
							[[RCResManager getInstance]imageForKey:kFootIconImage]];
		
		CGSize footsize = _footIconView.image.size;
		_footIconView.frame = CGRectMake(kPoiCellWidth - footsize.width - 5, 
										 12,
										 footsize.width, 
										 footsize.height);
	}
	return _footIconView;
}
@end
