//
//  RNAlbumItem.m
//  RRSpring
//
//  Created by sheng siglea on 4/11/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNAlbumItem.h"

@implementation RNAlbumItem
@synthesize albumType = _albumType;
@synthesize commentCount = _commentCount;
@synthesize createTime = _createTime;
@synthesize description = _description;
@synthesize hasPassword = _hasPassword;
@synthesize aid = _aid;
@synthesize img = _img;
@synthesize largeImg = _largeImg;
@synthesize location = _locationg;
@synthesize mainImg = _mainImg;
@synthesize size = _size;
@synthesize title = _title;
@synthesize uploadTime = _uploadTime;
@synthesize uid = _uid;
@synthesize visible = _visible;

- (id)initWithDictionary:(NSDictionary *)dict{
    if (self = [self init]) {
        self.albumType = [dict intForKey:@"album_type" withDefault:AlbumTypeUnknown];
        self.commentCount = [dict intForKey:@"comment_count" withDefault:0];
        self.createTime = [dict longLongForKey:@"create_time" withDefault:0];
        self.description = [dict stringForKey:@"description" withDefault:@""];
        self.hasPassword = [[dict objectForKey:@"has_password"] intValue] == 1;
        self.aid = [dict objectForKey:@"id"];
        self.img = [dict objectForKey:@"img"];
        self.largeImg = [dict objectForKey:@"large_img"];
        self.location = [dict objectForKey:@"location"];
        self.mainImg = [dict objectForKey:@"main_img"];
        self.size = [dict intForKey:@"size" withDefault:0];
        self.title = [dict objectForKey:@"title"];
        self.uploadTime = [dict longLongForKey:@"upload_time" withDefault:0];
        self.uid = [dict objectForKey:@"user_id"];
        self.visible = [dict intForKey:@"visible" withDefault:AlbumVisibleUnknown];
    }
    return self;
}
- (void)dealloc{
    self.description = nil;
    self.img = nil;
    self.aid = nil;
    self.uid = nil;
    self.largeImg = nil;
    self.location = nil;
    self.mainImg = nil;
    self.title = nil;
    [super dealloc];
}
@end
