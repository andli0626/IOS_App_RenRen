//
//  RNPoiTypeListViewController.h
//  RRSpring
//
//  Created by yi chen on 12-4-19.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNPublishBaseViewController.h"

@protocol RNPoiTypeListDelegate <NSObject>

/*
	选中一种类型
 */
- (void)didSelectedType :(NSNumber* )poiType poiTypeName : (NSString *)poiTypeName;

@end

@interface RNPoiTypeListViewController : RNPublishBaseViewController
{
	//poi类型
	NSMutableArray *_poiTypeArray;
	
	//poi类型名称
	NSMutableArray *_poiTypeNameArray;
	
	id<RNPoiTypeListDelegate>_delegate;
}
@property(nonatomic,retain)NSMutableArray *poiTypeArray;
@property(nonatomic,retain)NSMutableArray *poiTypeNameArray;
@property(nonatomic,assign)id<RNPoiTypeListDelegate> delegate;
@end
