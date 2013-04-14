//
//  RNPoiListCell.h
//  RRSpring
//
//  Created by yi chen on 12-4-14.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <UIKit/UIKit.h>

//cell高度
#define kPoidCellHeigth 60 

@interface RNPoiListCell : UITableViewCell
{
	//选中标记标签
	UIImageView *_isSelectedIconView;
	
	//是否被选中
	BOOL _bIsSelected;
	
	//是否报道过
	BOOL _bSelfCheckin;
	
	//地点的名称标签
	UILabel *_placeNameLabel;
	
	//总共的报道次数标签
	UILabel *_reportTimesLabel;
	
	//附加的图片,可能有个足迹icon
	UIImageView *_footIconView;
}

@property(nonatomic,retain)UIImageView *isSelectIconView;
@property(nonatomic,assign)BOOL bIsSelected;
@property(nonatomic,retain)UILabel *placeNameLabel;
@property(nonatomic,retain)UILabel *reportTimesLabel;
@property(nonatomic,retain)UIImageView *footIconView;

/*
	利用poi信息重置cell显示数据
 */
- (void)setWithPoiCellInfoDic: (NSDictionary *) cellInfoDic;

@end
