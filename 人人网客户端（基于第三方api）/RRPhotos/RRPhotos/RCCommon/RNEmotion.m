//
//  RNEmotion.m
//  RRSpring
//
//  Created by 玉平 孙 on 12-4-12.
//  Copyright (c) 2012年 RenRen.com. All rights reserved.
//

#import "RNEmotion.h"

@implementation RNEmotion
@synthesize emotionType = _emotionType;
@synthesize emotionPosition = _emotionPosition;
@synthesize emotionPath = _emotionPath;
@synthesize escapeCode = _escapeCode;
@synthesize netUrl=_netUrl;
- (void)dealloc{
    self.emotionPath = nil;
    self.escapeCode = nil;
    self.netUrl = nil;
    [super dealloc];
}

- (id) initWithDictionary:(NSDictionary*) dictionary{
    self = [super init];
    if (self) {
        self.emotionPath = [dictionary objectForKey:@"emotionPath"];
        self.escapeCode = [dictionary objectForKey:@"escapeCode"];
       
    }
    return self;
}

@end
