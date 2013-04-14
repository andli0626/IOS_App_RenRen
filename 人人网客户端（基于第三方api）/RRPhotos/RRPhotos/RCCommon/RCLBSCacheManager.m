//
//  RCLBSCacheManager.m
//  RRSpring
//
//  Created by gaosi on 12-4-8.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCLBSCacheManager.h"
#import "RCDataPersistenceAssistant.h"
#import "MKNetworkOperation.h"

static RCLBSCacheManager* instance;
#define MAX_LOCATION_CACHE_TIME 5*60 // 5 minutes
#define MAX_LOCATION_CACHE_DISTANCE 500; // 500 meters
#define MAX_LOCATE_TIME 60*60 // 60 minutes

@interface RCLBSCacheManager(Private)
- (void)updateLocCache:(NSMutableDictionary*)result;
@end

@implementation RCLBSCacheManager
@synthesize curLocPOICache = _curLocPOICache;
@synthesize photoLocPOICache = _photoLocPOICache;
@synthesize locCache = _locCache;
@synthesize locManager = _locManager;
@synthesize request = _request;
@synthesize delegate = _delegate;

- (void)dealloc
{
    RL_RELEASE_SAFELY(_curLocPOICache);
    RL_RELEASE_SAFELY(_photoLocPOICache);
    RL_RELEASE_SAFELY(_locCache);
    RL_RELEASE_SAFELY(_locManager);
    RL_RELEASE_SAFELY(_request);
    //RL_RELEASE_SAFELY(_delegates);
    [super dealloc];
}

+ (id)sharedInstance
{
    if (instance == nil)
    {
        instance = [[RCLBSCacheManager alloc] init];
    }
    
    return instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        _curLocPOICache = [[RCCurrentLocationPOICache alloc] init];
        _photoLocPOICache = [[RCPhotoLocationPOICache alloc] init];
        _locCache = [[RCLocationCache alloc] init];
        _locManager = [[RCLocationManager alloc] init];
        _locManager.delegate = self;
        //_delegates = [[NSMutableArray alloc] init];
        
        RCCurrentLocationPOICache* curLocPOICache = [RCDataPersistenceAssistant getCurrentLocationPOICache];
        if(curLocPOICache)
            self.curLocPOICache = curLocPOICache;
        
        RCPhotoLocationPOICache* photoLocPOICache = [RCDataPersistenceAssistant getPhotoLocationPOICache];
        if(photoLocPOICache)
            self.photoLocPOICache = photoLocPOICache;
        
        RCLocationCache* locationCache = [RCDataPersistenceAssistant getLocationCache];
        if(locationCache)
            self.locCache = locationCache;
        
        // 处理网络回调
        RCPreLocate *request = [[RCPreLocate alloc] init];
        request.onPreLocateFinished = ^(NSMutableDictionary* result){
            //用服务器返回的数据，更新locCache
            NSMutableArray *poiList = [result objectForKey:@"poi_list"];
            if(!poiList || [result objectForKey:@"lon_gps"] == nil ||[result objectForKey:@"lat_gps"] == nil){
                RCError* error = [RCError errorWithCode:100 errorMessage:NSLocalizedString(@"系统定位失败", @"系统定位失败")];
                if([self.delegate respondsToSelector:@selector(preLocateFailed:)]){
                    [self.delegate preLocateFailed:error];
                }
            }
            [self updateLocCache:result];
            
            //通知关心的对象
            if([self.delegate respondsToSelector:@selector(preLocateFinished:)]){
                [self.delegate preLocateFinished:self.locCache];
            }
            //[_delegates perform:@selector(preLocateFinished:) withObject:self.locCache];
        };
        
        request.onPrelocateFailed = ^(RCError* error) {
            if([self.delegate respondsToSelector:@selector(preLocateFailed:)]){
                [self.delegate preLocateFailed:error];
            }
            //[_delegates perform:@selector(preLocateFailed:) withObject:error];
        };
        
        self.request = request;
        RL_RELEASE_SAFELY(request);
    }
    return self;
}

- (void)saveCurrentLocationPOICache:(RCCurrentLocationPOICache*)cache
{
    self.curLocPOICache = cache;
    [RCDataPersistenceAssistant saveCurrentLocationPOICache:self.curLocPOICache];
}

- (void)savePhotoLocationPOICache:(RCPhotoLocationPOICache*)cache
{
    self.photoLocPOICache = cache;
    [RCDataPersistenceAssistant savePhotoLocationPOICache:self.photoLocPOICache];
}

- (void)saveLocationCache:(RCLocationCache*)cache
{
    self.locCache = cache;
    [RCDataPersistenceAssistant saveLocationCache:self.locCache];
}

- (void)saveCurrentLocationPOICache:(NSString*)pid poiName:(NSString*)poiName poiAddress:(NSString*)poiAddress 
                          longitude:(NSNumber*)longitude latitude:(NSNumber*)latitude
{
    RCCurrentLocationPOICache* cache = [[[RCCurrentLocationPOICache alloc] init] autorelease];
    cache.pid = pid;
    cache.poiName = poiName;
    cache.poiAddress = poiAddress;
    cache.longitude = longitude;
    cache.latitude = latitude;
    
    [self saveCurrentLocationPOICache:cache];
}

- (void)savePhotoLocationPOICache:(NSString*)pid poiName:(NSString*)poiName poiAddress:(NSString*)poiAddress 
longitude:(NSNumber*)longitude latitude:(NSNumber*)latitude
{
    RCPhotoLocationPOICache* cache = [[[RCPhotoLocationPOICache alloc] init] autorelease];
    cache.pid = pid;
    cache.poiName = poiName;
    cache.poiAddress = poiAddress;
    cache.longitude = longitude;
    cache.latitude = latitude;
    
    [self savePhotoLocationPOICache:cache];
}

- (void)saveLocationCache:(NSNumber*)longitude latitude:(NSNumber*)latitude gateSite:(NSString*)gateSite poiListFirstPage:(NSMutableArray*)poiList quickReportFlag:(NSNumber*)flag activitiesOfferedCount:(NSNumber*)count cacheTimeStamp:(NSDate*)timeStamp
{
    RCLocationCache* cache = [[[RCLocationCache alloc] init] autorelease];
    cache.longitude = longitude;
    cache.latitude = latitude;
    cache.gateSite = gateSite;
    cache.poiListFirstPage = poiList;
    cache.quickReportFlag = flag;
    cache.activitiesOfferedCount = count;
    cache.cacheTimeStamp = timeStamp;
    
    [self saveLocationCache:cache];
}

- (void)getLocCache
{
    if(self.locCache.cacheTimeStamp){
        NSDate* date = [NSDate date];
        NSTimeInterval timeInverval = [date timeIntervalSinceDate:_locCache.cacheTimeStamp];
        if(abs(timeInverval) < MAX_LOCATION_CACHE_TIME){
            //return _locCache;
            if([self.delegate respondsToSelector:@selector(preLocateFinished:)]){
                [self.delegate preLocateFinished:self.locCache];
            }
        }
        else{
            [self.locManager startUpdateLocation];
        }
    }
    else {
        [self.locManager startUpdateLocation];
    }
}

- (void)updateLocation:(BOOL)isForced
{
    if(!isForced){
        NSDate* date = [NSDate date];
        NSTimeInterval timeInverval = [_locCache.cacheTimeStamp timeIntervalSinceDate:date];
        if(timeInverval > MAX_LOCATE_TIME){
            [self.locManager startUpdateLocation];
        }
    }
    else{
        [self.locManager startUpdateLocation];
    }
}
/*
- (void)setDelegate:(id<RCLBSCacheManagerDelegate>)delegate
{
    if(delegate){
        [_delegates removeObject:delegate];
        [_delegates addObject:delegate];
    }
}
*/

- (void)setKeepLocOpening:(BOOL)isOpen
{
    [self.locManager setKeepOpening:isOpen];
}

- (void)updateLocCache:(NSMutableDictionary *)result
{
    //int count = [[result objectForKey:@"count"] intValue];
    NSMutableArray *poiList = [result objectForKey:@"poi_list"];
    NSMutableDictionary* infoDic = [result objectForKey:@"info"];
    NSDate* date = [NSDate date];
    if([result objectForKey:@"lon_gps"]){
        self.locCache.longitude = [NSNumber numberWithLong:[[result objectForKey:@"lon_gps"] longValue]];
    }
    if([result objectForKey:@"lat_gps"]){
        self.locCache.latitude = [NSNumber numberWithLong:[[result objectForKey:@"lat_gps"] longValue]];
    }
    if([infoDic objectForKey:@"address"]){
        self.locCache.gateSite = [infoDic objectForKey:@"address"];
    }
    if(poiList){
        self.locCache.poiListFirstPage = poiList;
    }
    if(date){
        self.locCache.cacheTimeStamp = date;
    }
    
    [RCDataPersistenceAssistant saveLocationCache:self.locCache];
}

- (CLLocationDistance)distanceFromLatAndLng:(NSNumber*)srcLat srcLng:(NSNumber*)srcLng tagLat:(NSNumber*)tagLat tagLng:(NSNumber*)tagLng
{
    CLLocation * srcLocation = [[[CLLocation alloc]initWithLatitude:[srcLat doubleValue] longitude:[srcLng doubleValue]] autorelease];
    CLLocation * tagLocation = [[[CLLocation alloc]initWithLatitude:[tagLat doubleValue] longitude:[tagLng doubleValue]] autorelease];
    CLLocationDistance newDistance = [srcLocation distanceFromLocation:tagLocation];
    return newDistance;
}

- (void)dealPublisherDataResponse:(MKNetworkOperation*)operation postData:(NSMutableDictionary*)postData isPostPhoto:(BOOL)isPostPhoto
{
    // 处理服务器返回的数据
    NSData* data = operation.responseData;
    
    NSData *tempReceivedData = [data gzipInflate];
    NSString *content;
    if(tempReceivedData && [tempReceivedData length] >0){
        content = [[[NSString alloc]
                    initWithData: tempReceivedData
                    encoding: NSUTF8StringEncoding] autorelease];
    } else {
        content = [[[NSString alloc]
                    initWithData: data
                    encoding: NSUTF8StringEncoding] autorelease];
    }
    
    if(content == nil)
        return;
    
    int jsonType = 0;
    if([content hasPrefix:@"["]){
        jsonType = 0;//RRJSONObjectTypeArray;
    } else {
        jsonType = 1;//RRJSONObjectTypeDictionary;
    }
    
    id rootObject = nil;
    switch (jsonType) {
        case 1: {
            NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
            if([content hasPrefix:@"["]) {
                NSArray* tempArray = [[CJSONDeserializer deserializer] deserializeAsArray:jsonData error:nil];	
                if (tempArray && [tempArray count] > 0) {
                    rootObject = [tempArray objectAtIndex:0];
                }
            } else {
                rootObject = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
            }
            
            //处理火星文
            if (!rootObject) {
                content =[[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
                
                // 没有必要使用UTF32BigEndian来编码。
                NSData *jsonDataHuo = [content dataUsingEncoding:NSUTF8StringEncoding]; 
                if([content hasPrefix:@"["]){
                    NSArray* tempArray = [[CJSONDeserializer deserializer] deserializeAsArray:jsonDataHuo error:nil];	
                    if (tempArray && [tempArray count] > 0) {
                        rootObject = [tempArray objectAtIndex:0];
                    }
                } else {
                    rootObject = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonDataHuo error:nil];		
                }
                rootObject = [RLUtility convertAsacIItoUTF8:rootObject];
                
                [content release];
            }
            
            break;
        }
        case 0: {
            // 没有必要使用UTF32BigEndian来编码。
            NSData *jsonDataArray = [content dataUsingEncoding:NSUTF8StringEncoding];
            rootObject = [[CJSONDeserializer deserializer] deserializeAsArray:jsonDataArray error:nil];
            
            //处理火星文
            if (!rootObject) {
                content =[[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
                
                NSData *jsonDataArrayHuo = [content dataUsingEncoding:NSUTF8StringEncoding];
                rootObject = [[CJSONDeserializer deserializer] deserializeAsArray:jsonDataArrayHuo error:nil]; // memory leaks?
                
                [content release];
            } else {
            }
            break;
        }
        default:
            break;
    }
    
    NSDictionary* dics = (NSDictionary*)rootObject;
    if([dics objectForKey:@"error_code"])
    {
        // 出错，暂时没处理，不更新缓存，直接返回
        NSLog(@"error_code:%@",[dics valueForKey:@"error_code"]);
        return;
    }
    // 处理返回数据中的pid
    NSLog(@"responseData:%@",dics);
    NSString* pid = nil;
    if(isPostPhoto){
        NSDictionary* lbs_data = [dics objectForKey:@"lbs_data"];
        if(lbs_data){
            if(![lbs_data objectForKey:@"pid"]) return;
            
            pid = [lbs_data objectForKey:@"pid"];
        }
    }
    else{
        if(![dics objectForKey:@"pid"]) return;
        
        pid = [dics objectForKey:@"pid"];
    }

    // 处理发送数据中包含的poi和定位信息
    NSString* poiName = nil;
    NSString* poiAddress = nil;
    NSNumber* newLatitude = nil;
    NSNumber* newLongitude = nil;
    if(postData){
        //处理post数据中的poi名和poi地址
        NSLog(@"postData:%@",postData);
        if(isPostPhoto){
            NSDictionary* place_data = [postData objectForKey:@"place_data"];
            if(place_data){
                poiName = [place_data objectForKey:@"place_name"];
                newLatitude = [NSNumber numberWithLong:[[dics objectForKey:@"gps_latitude"] longValue]];
                newLongitude = [NSNumber numberWithLong:[[dics objectForKey:@"gps_longitude"] longValue]];
            }
        }
        else{
            NSDictionary* place_data = [postData objectForKey:@"place_data"];
            if(place_data){
                poiName = [place_data objectForKey:@"place_name"];
                poiAddress = [place_data objectForKey:@"place_location"];
                newLatitude = self.locCache.latitude;
                newLongitude = self.locCache.longitude;
            }
        }
    }

    // 更新缓存
    if(pid){
        if(isPostPhoto){
            self.photoLocPOICache.pid = pid;
            self.photoLocPOICache.poiName = poiName;
            self.photoLocPOICache.latitude = newLatitude;
            self.photoLocPOICache.longitude = newLongitude;
            [RCDataPersistenceAssistant savePhotoLocationPOICache:self.photoLocPOICache];
        }
        else{
            self.curLocPOICache.pid = pid;
            self.curLocPOICache.poiName = poiName;
            self.curLocPOICache.poiAddress = poiAddress;
            self.curLocPOICache.latitude = newLatitude;
            self.curLocPOICache.longitude = newLongitude;
            [RCDataPersistenceAssistant saveCurrentLocationPOICache:self.curLocPOICache];
        }
    }

    // 用当前时间更新定位缓存时间
    NSDate* date = [NSDate date];
    self.locCache.cacheTimeStamp = date;
    [RCDataPersistenceAssistant saveLocationCache:self.locCache];
    
    return;   
}

#pragma mark - RCLocationManagerDelegate 
- (void)RCLocMgrNewLocation:(CLLocation*)location
{
    NSLog(@"定位结束,需要去向服务器请求预定位结果");
    //需要配置一些请求的参数
    
    if(location){
        if(self.request){
            CLLocationCoordinate2D tmp = location.coordinate;
            NSLog(@"longitude=%f,latitude=%f",tmp.longitude,tmp.latitude);
            self.request.longitude = [NSNumber numberWithDouble:tmp.longitude];
            self.request.latitude = [NSNumber numberWithDouble:tmp.latitude];
            [self.request sendRequest];
        }
    }
    else {
        RCError* error = [RCError errorWithCode:100 errorMessage:NSLocalizedString(@"系统定位失败", @"系统定位失败")];
        if([self.delegate respondsToSelector:@selector(preLocateFailed:)]){
            [self.delegate preLocateFailed:error];
        }
        //[_delegates perform:@selector(preLocateFailed:) withObject:error];
    }
}

@end
