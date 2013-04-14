//
//  RCPhotoLocationPOICache.m
//  RRSpring
//
//  Created by gaosi on 12-4-8.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCPhotoLocationPOICache.h"

@implementation RCPhotoLocationPOICache
@synthesize longitude = _longitude;
@synthesize latitude = _latitude;
@synthesize poiName = _poiName;
@synthesize poiAddress = _poiAddress;
@synthesize pid= _pid;

- (void) dealloc {
    RL_RELEASE_SAFELY(_longitude);
    RL_RELEASE_SAFELY(_latitude);
    RL_RELEASE_SAFELY(_poiName);
    RL_RELEASE_SAFELY(_poiAddress);
    RL_RELEASE_SAFELY(_pid);
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        _longitude = [[NSNumber alloc] init];
        _latitude = [[NSNumber alloc] init];
        _poiName = [[NSString alloc] init];
        _poiAddress = [[NSString alloc] init];
        _pid = [[NSString alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark NSCoding methods
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
    self.longitude = [decoder decodeObjectForKey:@"longtitude"];
    self.latitude = [decoder decodeObjectForKey:@"latitude"];
    self.poiName = [decoder decodeObjectForKey:@"poiName"];
    self.poiAddress = [decoder decodeObjectForKey:@"poiAddress"];
    self.pid = [decoder decodeObjectForKey:@"pid"];
	return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.longitude forKey:@"longtitude"];
	[encoder encodeObject:self.latitude forKey:@"latitude"];
	[encoder encodeObject:self.poiName forKey:@"poiName"];
	[encoder encodeObject:self.poiAddress forKey:@"poiAddress"];
	[encoder encodeObject:self.pid forKey:@"pid"];
}

@end
