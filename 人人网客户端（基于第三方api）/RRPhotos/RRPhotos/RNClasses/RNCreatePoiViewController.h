//
//  RNCreatePoiViewController.h
//  RRSpring
//
//  Created by yi chen on 12-4-17.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//


#import "RNPublishBaseViewController.h"
#import "RCPublishPost.h"
#import "RNPoiTypeListViewController.h"
@interface RNCreatePoiViewController : RNPublishBaseViewController<UITextFieldDelegate,RNPoiTypeListDelegate,UIAlertViewDelegate>
{
	//POI名称
	UITextField *_poiNameField;
	
	//POI地点
	UITextField *_poiAddressField;
	
	//POI类型
	UITextField *_poiTypeField;
	
	
	NSString *_poiName;
	NSString *_poiAddress;
	NSNumber *_poiType;
	
	//网络请求
	RCBaseRequest *_baseRequest;
	
	NSMutableDictionary *_query;
}

@property(nonatomic,retain)UITextField *poiNameField;
@property(nonatomic,retain)UITextField *poiAddressField;
@property(nonatomic,retain)UITextField *poiTypeField;
@property(nonatomic,copy)NSString *poiName;
@property(nonatomic,copy)NSString *poiAddress;
@property(nonatomic,copy)NSNumber *poiType;
@property(nonatomic,retain)	RCBaseRequest *baseRequest;
@property(nonatomic,retain) NSMutableDictionary *query;

/*
	初始化信息
	@PoiInfoDic :
 request:
	name	 string	 POI的名字
 optional:
	address	 string	 POI的地址
	type	 string	 POI的类型
	lat_gps	 long	 gps纬度，缺省值为0
	lon_gps	 long	 gps经度，缺省值为0
	d	     int	 使用的是否是真实经纬度，若是，则设1，若已经使用的是偏转过的经纬度，则设为0
 */

- (id)initWithPoiInfoDic:(NSMutableDictionary *)poiInfoDic;

@end
