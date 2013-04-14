//
//  RCLocationCache.m
//  RRSpring
//
//  Created by gaosi on 12-4-8.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCLocationCache.h"

@implementation RCLocationCache
@synthesize longitude = _longitude;
@synthesize latitude = _latitude;
@synthesize gateSite = _gateSite;
@synthesize poiListFirstPage = _poiListFirstPage;
@synthesize quickReportFlag = _quickReportFlag;
@synthesize activitiesOfferedCount = _activitiesOfferedCount;
@synthesize cacheTimeStamp = _cacheTimeStamp;

- (void) dealloc {
    RL_RELEASE_SAFELY(_longitude);
    RL_RELEASE_SAFELY(_latitude);
    RL_RELEASE_SAFELY(_gateSite);
    RL_RELEASE_SAFELY(_poiListFirstPage);
    RL_RELEASE_SAFELY(_cacheTimeStamp);
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        _longitude = [[NSNumber alloc] init];
        _latitude = [[NSNumber alloc] init];
        _gateSite = [[NSString alloc] init];
        _poiListFirstPage = [[NSMutableArray alloc] init];
        _cacheTimeStamp = [[NSDate alloc] init];
        _quickReportFlag = [[NSNumber alloc] init];
        _activitiesOfferedCount = [[NSNumber alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark NSCoding methods
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
    self.longitude = [decoder decodeObjectForKey:@"longtitude"];
    self.latitude = [decoder decodeObjectForKey:@"latitude"];
    self.gateSite = [decoder decodeObjectForKey:@"gateSite"];
    self.poiListFirstPage = [decoder decodeObjectForKey:@"poiListFirstPage"];
    self.cacheTimeStamp = [decoder decodeObjectForKey:@"cacheTimeStamp"];
    self.quickReportFlag = [decoder decodeObjectForKey:@"quickReportFlag"];
    self.activitiesOfferedCount = [decoder decodeObjectForKey:@"activitiesOfferedCount"];
	return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.longitude forKey:@"longtitude"];
	[encoder encodeObject:self.latitude forKey:@"latitude"];
	[encoder encodeObject:self.gateSite forKey:@"gateSite"];
	[encoder encodeObject:self.poiListFirstPage forKey:@"poiListFirstPage"];
	[encoder encodeObject:self.cacheTimeStamp forKey:@"cacheTimeStamp"];
	[encoder encodeObject:self.quickReportFlag forKey:@"quickReportFlag"];
	[encoder encodeObject:self.activitiesOfferedCount forKey:@"activitiesOfferedCount"];
}

@end
