//
//  RCLocationManager.m
//  RRSpring
//
//  Created by gaosi on 12-4-9.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCLocationManager.h"

@implementation RCLocationManager
@synthesize locationManager = _locationManager;
@synthesize currentLoc = _currentLoc;
@synthesize currentHead = _currentHead;
@synthesize delegate = _delegate;
@synthesize keepOpening = _keepOpening;

- (void)dealloc
{
    RL_RELEASE_SAFELY(_locationManager);
    RL_RELEASE_SAFELY(_currentLoc);
    RL_RELEASE_SAFELY(_currentHead);
    [super dealloc];
}

- (id)init
{
    self = [super init];  
    if (self != nil) {  
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self; 
        //self.locationManager.distanceFilter = 100.0f;
        self.locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters;
        self.currentLoc = nil;  
        self.keepOpening = NO;
        _isLocating = NO;
        //[self.locationManager startUpdatingLocation];
    }  
    return self;  
}

- (void)startUpdateLocation
{
    // 如果正在定位，
    if(_isLocating){
        return;
    }
    _isLocating = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdateLocation
{
    _isLocating = NO;
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate 
 
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{  
    
}  

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager 
{  
    return YES;  
}  

- (void)locationManager:(CLLocationManager *)manager  
didUpdateToLocation:(CLLocation *)newLocation  fromLocation:(CLLocation *)oldLocation  
{ 
    if(!_isLocating)
        return;
    
    if(!self.keepOpening)
        [self stopUpdateLocation];
    _isLocating = NO;
    self.currentLoc = newLocation;

    [self.delegate RCLocMgrNewLocation:self.currentLoc];
    return;  
}  

// Called when there is an error getting the location  
// TODO: Update this function to return the proper info in the proper UI fields  
- (void)locationManager:(CLLocationManager *)manager  
       didFailWithError:(NSError *)error  
{  
    // stop locate
    if(!self.keepOpening)
        [self stopUpdateLocation];
    _isLocating = NO;
    
    NSMutableString *errorString = [[[NSMutableString alloc] init] autorelease];  
    
    if ([error domain] == kCLErrorDomain) {  
        
        // We handle CoreLocation-related errors here  
        
        switch ([error code]) {  
                // This error code is usually returned whenever user taps "Don't Allow" in response to  
                // being told your app wants to access the current location. Once this happens, you cannot  
                // attempt to get the location again until the app has quit and relaunched.  
                //  
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user  
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.  
                //  
            case kCLErrorDenied:  
                [errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationDenied", nil)];   
                break;  
                
                // This error code is usually returned whenever the device has no data or WiFi connectivity,  
                // or when the location cannot be determined for some other reason.  
                //  
                // CoreLocation will keep trying, so you can keep waiting, or prompt the user.  
                //  
            case kCLErrorLocationUnknown:  
                [errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationUnknown", nil)];  
                break;  
                
                // We shouldn't ever get an unknown error code, but just in case...  
                //  
            default:  
                [errorString appendFormat:@"%@ %d\n", NSLocalizedString(@"GenericLocationError", nil), [error code]];    
                break;  
        }  
    } else {  
        // We handle all non-CoreLocation errors here  
        // (we depend on localizedDescription for localization)  
        [errorString appendFormat:@"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];  
        [errorString appendFormat:@"Description: \"%@\"\n", [error localizedDescription]];   
    }  
    
    // TODO: Send the delegate the alert?  
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"定位失败" 
                          message:errorString 
                          delegate:nil 
                          cancelButtonTitle:@"Okay" 
                          otherButtonTitles:nil]; 
    [alert show]; 
    [alert release];
}

@end
