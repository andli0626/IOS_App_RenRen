//
//  RCPageInfo.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-3-20.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RCPageInfo.h"

@implementation RCPageInfo

@synthesize pageId          = _pageId;
@synthesize fansNumber      = _fansNumber;
@synthesize pageName        = _pageName;
@synthesize classiFication  = _classiFication;
@synthesize thepageChecked  = _thepageChecked;
@synthesize headUrl         = _headUrl;
@synthesize desc            = _desc;
@synthesize isFan           = _isFan;

- (void) dealloc {
	[_pageId release];
	[_fansNumber release];
	[_pageName release];
    [_thepageChecked release];
	[_classiFication release];
	[_headUrl release];
    [_desc release];
    [_isFan release];
	[super dealloc];
}
- (id) init {
	
	if (self = [super init]) {
		
	}
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithDictionary:(NSDictionary*) dictionary
{
    if (self = [super init]) {
        self.pageId = [dictionary objectForKey:@"id"];
		self.pageName = [dictionary objectForKey:@"page_name"];
		self.headUrl = [dictionary objectForKey:@"head_url"];
		self.desc = [dictionary objectForKey:@"desc"];
		self.classiFication = [dictionary objectForKey:@"classification"];
		self.fansNumber = [dictionary objectForKey:@"fans_count"];
		self.isFan = [dictionary objectForKey:@"is_fan"];
        self.thepageChecked = [dictionary objectForKey:@"is_checked"];
    }
    
	return self;
}
- (NSDictionary*)encodeWithDictionary {
    NSDictionary *pageInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:self.pageId,@"id",
                                 self.pageName,@"page_name",
                                 self.headUrl ,@"head_url" ,
                                 self.desc    ,@"desc"     ,
                                 self.classiFication,@"classification",
                                 self.fansNumber ,@"fans_count",
                                 self.isFan,@"is_fan",
                                 self.thepageChecked,@"is_checked",
                                 nil];
    return pageInfoDic;
}
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [self init]) {
		self.pageId = [decoder decodeObjectForKey:@"id"];
		self.pageName = [decoder decodeObjectForKey:@"page_name"];
		self.headUrl = [decoder decodeObjectForKey:@"head_url"];
		self.desc = [decoder decodeObjectForKey:@"desc"];
		self.classiFication = [decoder decodeObjectForKey:@"classification"];
		self.fansNumber = [decoder decodeObjectForKey:@"fans_count"];
		self.isFan = [decoder decodeObjectForKey:@"is_fan"];
        self.thepageChecked = [decoder decodeObjectForKey:@"is_checked"];
	}
	return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.pageId forKey:@"id"];
	[encoder encodeObject:self.pageName forKey:@"page_name"];
	[encoder encodeObject:self.headUrl forKey:@"head_url"];
	[encoder encodeObject:self.desc forKey:@"desc"];
	[encoder encodeObject:self.classiFication forKey:@"classification"];
	[encoder encodeObject:self.fansNumber forKey:@"fans_count"];
	[encoder encodeObject:self.isFan forKey:@"is_fan"];
    [encoder encodeObject:self.thepageChecked forKey:@"is_checked"];
}

@end
