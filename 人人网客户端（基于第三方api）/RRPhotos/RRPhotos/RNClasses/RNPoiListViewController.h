//
//  RNPoiListViewController.h
//  RRSpring
//
//  Created by yi chen on 12-4-14.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBaseViewController.h"
#import "RRRefreshTableHeaderView.h"
#import "RNPoiListCell.h"
#import "RCLBSCacheManager.h"
#import "RCLocationCache.h"
#import "RNPoiListModel.h"
#import "RNCreatePoiViewController.h"

@protocol RNPoiListDelegate <NSObject>
/*
	选中poi里面的一项，信息回调
 */
- (void)didSlectedPoiItem:(NSDictionary *)poiItemInfoDic;

@end

@interface RNPoiListViewController : RNPublishBaseViewController<RCLBSCacheManagerDelegate,UISearchDisplayDelegate,RRRefreshTableHeaderDelegate>
{
	id<RNPoiListDelegate> _delegete;
	
	//所有的poi信息
	NSMutableArray *_poiItemsAll;

	//缓存的poi列表信息
	NSMutableArray *_poiItemsCache;
	
	//网络请求部分的poi列表信息
	NSMutableArray *_poiItemsNet;
	
	//搜索结果
	NSMutableArray *_poiItemsSearchResult;
	
	//下拉刷新
	RRRefreshTableHeaderView *_rrRefreshTableHeaderView;
	//正在更新列表数据标志
	BOOL _bIsLoading;
	
	//附加的加载指示器
	UIActivityIndicatorView *_indicator;

	/* -------搜索相关------- */
	UISearchDisplayController *_rrSearchDisplayController;
	NSTimer*                _pauseTimer;
    BOOL                    _pausesBeforeSearching;
	
	/* ------网络请求相关------- */
	//经度
	NSNumber* _longitude;
	//纬度
    NSNumber* _latitude;
	
}
@property(nonatomic,assign)id<RNPoiListDelegate> delegate;
@property(nonatomic,retain)NSMutableArray *poiItemsAll;
@property(nonatomic,retain)NSMutableArray *poiItemsCache;
@property(nonatomic,retain)NSMutableArray *poiItemsNet;
@property(nonatomic,retain)NSMutableArray *poiItemsSearchResult;

@property(nonatomic,retain)RRRefreshTableHeaderView *rrRefreshTableHeaderView;
@property(nonatomic,retain)	UIActivityIndicatorView *indicator;
@property(nonatomic,retain)UISearchDisplayController *rrSearchDisplayController;

@property(nonatomic,copy)NSNumber *longitude;
@property(nonatomic,copy)NSNumber *latitude;

@end
