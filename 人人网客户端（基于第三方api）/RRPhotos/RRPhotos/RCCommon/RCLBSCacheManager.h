//
//  RCLBSCacheManager.h
//  RRSpring
//
//  Created by gaosi on 12-4-8.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCLocationCache.h"
#import "RCCurrentLocationPOICache.h"
#import "RCPhotoLocationPOICache.h"
#import "RCLocationManager.h"
#import "RCPreLocate.h"

@protocol RCLBSCacheManagerDelegate<NSObject>
@optional
- (void)preLocateFinished:(RCLocationCache*)location;
- (void)preLocateFailed:(RCError*)error;
@end

@interface RCLBSCacheManager : NSObject<RCLocationManagerDelegate>{
    RCCurrentLocationPOICache* _curLocPOICache;
    RCPhotoLocationPOICache* _photoLocPOICache;
    RCLocationCache* _locCache;
    RCLocationManager* _locManager;
    RCPreLocate* _request;
    id<RCLBSCacheManagerDelegate> _delegate;
    //由于此类是单件类，所以在一段时间类可能会有很多delegate
    //NSMutableArray *_delegates;
    
}
@property (nonatomic, retain)RCCurrentLocationPOICache* curLocPOICache;
@property (nonatomic, retain)RCPhotoLocationPOICache* photoLocPOICache;
@property (nonatomic, retain)RCLocationCache* locCache;
@property (nonatomic, retain, readonly)RCLocationManager* locManager;
@property (nonatomic, retain)RCPreLocate* request;
@property (nonatomic, assign)id<RCLBSCacheManagerDelegate> delegate;

+ (RCLBSCacheManager*)sharedInstance;
/**
 *以下6个方法，会更新内存中的缓存数据，并立即更新本地缓存
 */
- (void)saveCurrentLocationPOICache:(RCCurrentLocationPOICache*)cache;
- (void)savePhotoLocationPOICache:(RCPhotoLocationPOICache*)cache;
- (void)saveLocationCache:(RCLocationCache*)cache;

- (void)saveCurrentLocationPOICache:(NSString*)pid poiName:(NSString*)poiName poiAddress:(NSString*)poiAddress 
                          longitude:(NSNumber*)longitude latitude:(NSNumber*)latitude;
- (void)savePhotoLocationPOICache:(NSString*)pid poiName:(NSString*)poiName poiAddress:(NSString*)poiAddress 
                          longitude:(NSNumber*)longitude latitude:(NSNumber*)latitude;
- (void)saveLocationCache:(NSNumber*)longitude latitude:(NSNumber*)latitude gateSite:(NSString*)gateSite poiListFirstPage:(NSMutableArray*)poiList quickReportFlag:(NSNumber*)flag activitiesOfferedCount:(NSNumber*)count cacheTimeStamp:(NSDate*)timeStamp;

/**
 *此方法进行了定位缓存判断，如果定位缓存失效（当前时间与缓存时间相差5分钟以上），则去请求新的定位信息。
 *如果想直接取缓存信息，请使用成员locCache中的信息
 */
- (void)getLocCache;

/**
 *如果isForced为true,则会直接去请求当前定位信息，
 *如果isForced为false,则会判断当前时间与缓存时间差距，如果相差60分钟以上，则去请求新的定位信息
 */
- (void)updateLocation:(BOOL)isForced;

/**
 *设置是否保持定位模块一直开启
 */
- (void)setKeepLocOpening:(BOOL)isOpen;

/**
 *计算两个经纬度之间的距离,返回整型
 */
- (CLLocationDistance)distanceFromLatAndLng:(NSNumber*)srcLat srcLng:(NSNumber*)srcLng tagLat:(NSNumber*)tagLat tagLng:(NSNumber*)tagLng;

/**
 *处理publisher返回的数据，如果包含POI信息或照片信息，则需要更新缓存
 */
- (void)dealPublisherDataResponse:(MKNetworkOperation*)operation postData:(NSMutableDictionary*)postData isPostPhoto:(BOOL)isPostPhoto;

@end
