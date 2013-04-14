//
//  RCPreLocate.m
//  RRSpring
//
//  Created by  on 12-4-12.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCPreLocate.h"

#define LNGANDLAT 1000000

@implementation RCPreLocate
@synthesize longitude = _longitude;
@synthesize latitude = _latitude;
@synthesize onPreLocateFinished = _onPreLocateFinished;
@synthesize onPrelocateFailed = _onPrelocateFailed;

-(void)dealloc
{
    RL_RELEASE_SAFELY(_longitude);
    RL_RELEASE_SAFELY(_latitude);
    RL_RELEASE_SAFELY(_onPreLocateFinished);
    RL_RELEASE_SAFELY(_onPrelocateFailed);
    [super dealloc];
}

-(id)init
{
	if (self = [super init]) {
		self.onCompletion = ^(NSMutableDictionary *result)
		{		
			//回调通知用户结果
            NSLog(@"onCompletion:%@",result);
			if (self.onPreLocateFinished) {
				self.onPreLocateFinished(result);
			}
		};
    
        self.onError = ^(RCError* error){
            NSLog(@"onError:%@",error);
            if(self.onPrelocateFailed){
                self.onPrelocateFailed(error);
            }
        };
	}
	return self;
}

- (void)sendRequest
{
    NSMutableDictionary* dics = [NSMutableDictionary dictionary];
    long longitude = [self.longitude doubleValue]*LNGANDLAT;
    long latitude = [self.latitude doubleValue]*LNGANDLAT;
    [dics setObject:[NSNumber numberWithLong:longitude] forKey:@"lon_gps"];
    [dics setObject:[NSNumber numberWithLong:latitude] forKey:@"lat_gps"];
/*    NSMutableDictionary* dicsToJson = [NSMutableDictionary dictionary];
    [dicsToJson setObject:[NSNumber numberWithLong:longitude] forKey:@"gps_longitude"];
    [dicsToJson setObject:[NSNumber numberWithLong:latitude] forKey:@"gps_latitude"];
    [dicsToJson setObject:[NSNumber numberWithInt:1] forKey:@"d"];
    [dicsToJson setObject:[NSNumber numberWithInt:1] forKey:@"locate_type"];
    [dicsToJson setObject:[NSNumber numberWithInt:2] forKey:@"source_type"];
    [dicsToJson setObject:@"" forKey:@"place_name"];
    NSString* jsonString = [dicsToJson JSONString];
    [dics setValue:jsonString forKey:@"latlon"];*/
    RCMainUser *mainUser = [RCMainUser getInstance];
    [dics setObject:mainUser.sessionKey forKey:@"session_key"];
    NSLog(@"dics = %@",dics);
    [self sendQuery:dics withMethod: @"place/preLocate"];
}

@end
