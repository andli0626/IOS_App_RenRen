//
//  RCLocationManager.h
//  RRSpring
//
//  Created by gaosi on 12-4-9.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol RCLocationManagerDelegate<NSObject>
@optional
- (void)RCLocMgrNewLocation:(CLLocation*)location;
@end

@interface RCLocationManager : NSObject<CLLocationManagerDelegate>{
    CLLocationManager* _locationManager;
    CLLocation* _currentLoc;
    CLHeading* _currentHead;
    id<RCLocationManagerDelegate> _delegate;
    BOOL _keepOpening;
@private
    BOOL _isLocating;
}
@property (nonatomic, retain)CLLocationManager* locationManager;
@property (nonatomic, retain)CLLocation* currentLoc;
@property (nonatomic, retain)CLHeading* currentHead;
@property (nonatomic, assign)id<RCLocationManagerDelegate> delegate;
@property (nonatomic, assign)BOOL keepOpening;

- (void)startUpdateLocation;
- (void)stopUpdateLocation;

@end
