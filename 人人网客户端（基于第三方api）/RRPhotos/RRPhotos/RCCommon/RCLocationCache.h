//
//  RCLocationCache.h
//  RRSpring
//
//  Created by gaosi on 12-4-8.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCLocationCache : NSObject<NSCoding>{
    NSNumber* _longitude;
    NSNumber* _latitude;
    NSString* _gateSite;
    NSMutableArray* _poiListFirstPage;
    NSNumber* _quickReportFlag;
    NSNumber* _activitiesOfferedCount;
    NSDate* _cacheTimeStamp;
}
@property (nonatomic, retain)NSNumber* longitude;
@property (nonatomic, retain)NSNumber* latitude;
@property (nonatomic, copy)NSString* gateSite;
@property (nonatomic, retain)NSMutableArray* poiListFirstPage;
@property (nonatomic, assign)NSNumber* quickReportFlag;
@property (nonatomic, assign)NSNumber* activitiesOfferedCount;
@property (nonatomic, retain)NSDate* cacheTimeStamp;

@end
