//
//  RNPhotoItem.m
//  RRSpring
//
//  Created by sheng siglea on 4/5/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNPhotoItem.h"

@implementation RNPhotoItem
 

@synthesize albumId = _albumId;
@synthesize albumName = _albumName;
@synthesize caption = _caption;
@synthesize commentCount = _commentCount;
@synthesize pid = _pid;
@synthesize imgHead = _imgHead;
@synthesize imgLarge = _imgLarge;
@synthesize imgLargeHeight = _imgLargeHeight;
@synthesize imgLargeWidth = _imgLargeWidth;
@synthesize imgMain = _imgMain;
@synthesize imgOrigin =_imgOrigin;
@synthesize imgOriginHeight = _imgOriginHeight;
@synthesize imgOriginWidth = _imgOriginWidth;
@synthesize time = _time;
@synthesize userId = _userId;
@synthesize userName = _userName;
@synthesize viewCount = _viewCount;
@synthesize lbsItem = _lbsItem;

- (id)initWithDictionary:(NSDictionary *)dict{
    if (self = [self init]) {
        self.albumId = [dict objectForKey:@"album_id"];
        self.albumName = [dict stringForKey:@"album_name" withDefault:@""];
        self.caption = [dict stringForKey:@"caption" withDefault:@""];
        self.commentCount = [dict intForKey:@"comment_count" withDefault:0] ;
        self.pid = [dict objectForKey:@"id"];
        self.imgHead = [dict stringForKey:@"img_head" withDefault:@""];
        self.imgLarge = [dict stringForKey:@"img_large" withDefault:@""];
        self.imgLargeHeight = [dict floatForKey:@"img_large_height" withDefault:.0];
        self.imgLargeWidth = [dict floatForKey:@"img_large_width" withDefault:.0];
        self.imgMain = [dict stringForKey:@"img_main" withDefault:@""];
        self.imgOrigin = [dict stringForKey:@"img_origin" withDefault:@""];
        self.imgOriginHeight = [dict floatForKey:@"img_origin_height" withDefault:.0];
        self.imgOriginWidth = [dict floatForKey:@"img_origin_width" withDefault:.0];
        self.time = [dict timeIntervalForKey:@"time" withDefault:.0];
        self.userId = [dict objectForKey:@"user_id"];
        self.userName = [dict stringForKey:@"user_name" withDefault:@""];
        self.viewCount = [dict intForKey:@"view_count" withDefault:0];
        if ([[dict allKeys] containsObject:@"lbs_data"]) {
            RNPhotoLbsItem *lbs = [[RNPhotoLbsItem alloc] initWithDictionary:[dict objectForKey:@"lbs_data"]];
            self.lbsItem = lbs;
            [lbs release];
        }
    }
    return self;
}
- (void)dealloc{
    self.albumId = nil;
    self.albumName = nil;
    self.caption = nil;
    self.pid = nil;
    self.imgHead = nil;
    self.imgLarge = nil;
    self.imgMain = nil;
    self.imgOrigin = nil;
    self.userId = nil;
    self.userName = nil;
    self.lbsItem = nil;
    [super dealloc];
}
@end

@implementation RNPhotoLbsItem

@synthesize lbsId = _lbsId;
@synthesize lbsPid = _lbsPid;
@synthesize pname = _pname;
@synthesize location = _location;
@synthesize  longitude = _longitude;
@synthesize  latitude = _latitude;

- (id)initWithDictionary:(NSDictionary *)dict{
    if (self = [self init]) {
        self.lbsId = [dict longLongForKey:@"id" withDefault:0];
        self.lbsPid = [dict stringForKey:@"pid" withDefault:@""];
        self.pname = [dict stringForKey:@"pname" withDefault:@""];
        self.location = [dict stringForKey:@"location" withDefault:@""];
        self.longitude = [dict longLongForKey:@"longitude" withDefault:0];
        self.latitude = [dict longLongForKey:@"latitude" withDefault:0];
    }
    return self;
}
- (void)dealloc{
    self.lbsPid = nil;
    self.pname = nil;
    self.location = nil;
    [super dealloc];
}
@end
/*
 "album_id" = 587674045;
 "album_name" = bbbb;
 caption = "";
 "comment_count" = 0;
 id = 5741075722;
 "img_head" = "http://fmn.rrfmn.com/fmn058/20120329/1505/head_qcWN_6a350000022f125f.jpg";
 "img_large" = "http://fmn.rrfmn.com/fmn058/20120329/1505/large_qcWN_6a350000022f125f.jpg";
 "img_large_height" = 540;
 "img_large_width" = 720;
 "img_main" = "http://fmn.rrfmn.com/fmn058/20120329/1505/main_qcWN_6a350000022f125f.jpg";
 "img_origin" = "http://fmn.rrfmn.com/fmn058/20120329/1505/original_qcWN_6a350000022f125f.jpg";
 "img_origin_height" = 600;
 "img_origin_width" = 800;
 time = 1333004962000;
 "user_id" = 439643362;
 "user_name" = "\U6c88\U519b\U8230";
 "view_count" = 0;
 "lbs_data" =             {
 id = 280880887;
 latitude = 39960450;
 location = "";
 longitude = 116440540;
 pid = "";
 pname = "\U9999\U6cb3\U56ed";
 };
 
 */