//
//  RCCurrentLocationPOICache.h
//  RRSpring
//
//  Created by gaosi on 12-4-8.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCCurrentLocationPOICache : NSObject<NSCoding>{
    NSString* _pid;
    NSString* _poiName;
    NSString* _poiAddress;
    // 
    NSNumber* _longitude;
    NSNumber* _latitude;
}
@property (nonatomic, copy)NSString* pid;
@property (nonatomic, copy)NSString* poiName;
@property (nonatomic, copy)NSString* poiAddress;
@property (nonatomic, retain)NSNumber* longitude;
@property (nonatomic, retain)NSNumber* latitude;

@end
